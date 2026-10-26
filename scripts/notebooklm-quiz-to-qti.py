"""Convert a checked NotebookLM quiz (quiz.md) into a Canvas QTI 1.2 import package.

Usage: python3 scripts/notebooklm-quiz-to-qti.py <quiz.md> <out.zip> "<quiz title>"

quiz.md format (what NotebookLM's chat produces, after checking):

    #### **Question 1**
    <stem>
    - **A)** <choice>
    - **B)** <choice>
    **Answer:** **B) ...**
    **Explanation:** <one or two sentences>

Only the quiz section is read; the flashcards after it are ignored. Math written as
\\( ... \\) becomes \( ... \), which Canvas renders as LaTeX. Import in Canvas with
Settings > Import Course Content > QTI .zip file, then preview every question.
"""
import re
import sys
import zipfile
from xml.sax.saxutils import escape


def clean(text):
    """Markdown fragment -> HTML-safe text for Canvas."""
    text = text.strip()
    text = text.replace('\\\\(', '\\(').replace('\\\\)', '\\)')
    text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
    return text


def parse(md):
    quiz_part = md.split('### **Options Flashcards')[0]
    blocks = re.split(r'^#### \*\*Question (\d+)\*\*\s*$', quiz_part, flags=re.M)[1:]
    questions = []
    for number, body in zip(blocks[0::2], blocks[1::2]):
        lines = [l for l in body.strip().splitlines() if l.strip() and l.strip() != '---']
        stem, choices, answer, explanation = [], {}, None, ''
        for line in lines:
            m = re.match(r'^- \*\*([A-D])\)\*\*\s*(.+)$', line)
            if m:
                choices[m.group(1)] = m.group(2)
            elif line.startswith('**Answer:**'):
                answer = re.search(r'\*\*Answer:\*\*\s*\*\*([A-D])\)', line).group(1)
            elif line.startswith('**Explanation:**'):
                explanation = line[len('**Explanation:**'):]
            elif not choices:
                stem.append(line)
        assert answer in choices and len(choices) == 4, f'question {number} is incomplete'
        questions.append(dict(n=int(number), stem=' '.join(stem), choices=choices,
                              answer=answer, explanation=explanation))
    return questions


def item_xml(q):
    ident = f'q{q["n"]}'
    labels = ''.join(
        f'<response_label ident="{k}"><material><mattext texttype="text/html">'
        f'{escape(clean(v))}</mattext></material></response_label>'
        for k, v in sorted(q['choices'].items()))
    return f'''<item ident="{ident}" title="Question {q["n"]}">
<itemmetadata><qtimetadata>
<qtimetadatafield><fieldlabel>question_type</fieldlabel><fieldentry>multiple_choice_question</fieldentry></qtimetadatafield>
<qtimetadatafield><fieldlabel>points_possible</fieldlabel><fieldentry>1.0</fieldentry></qtimetadatafield>
</qtimetadata></itemmetadata>
<presentation>
<material><mattext texttype="text/html">{escape(clean(q["stem"]))}</mattext></material>
<response_lid ident="response1" rcardinality="Single"><render_choice>{labels}</render_choice></response_lid>
</presentation>
<resprocessing>
<outcomes><decvar maxvalue="100" minvalue="0" varname="SCORE" vartype="Decimal"/></outcomes>
<respcondition continue="Yes"><conditionvar><other/></conditionvar><displayfeedback feedbacktype="Response" linkrefid="general_fb"/></respcondition>
<respcondition continue="No"><conditionvar><varequal respident="response1">{q["answer"]}</varequal></conditionvar><setvar action="Set" varname="SCORE">100</setvar></respcondition>
</resprocessing>
<itemfeedback ident="general_fb"><flow_mat><material><mattext texttype="text/html">{escape(clean(q["explanation"]))}</mattext></material></flow_mat></itemfeedback>
</item>'''


def build(md_path, zip_path, title):
    questions = parse(open(md_path).read())
    quiz_id = re.sub(r'[^A-Za-z0-9]+', '_', title).strip('_').lower()
    assessment = f'''<?xml version="1.0" encoding="UTF-8"?>
<questestinterop xmlns="http://www.imsglobal.org/xsd/ims_qtiasiv1p2">
<assessment ident="{quiz_id}" title="{escape(title)}">
<qtimetadata><qtimetadatafield><fieldlabel>cc_maxattempts</fieldlabel><fieldentry>unlimited</fieldentry></qtimetadatafield></qtimetadata>
<section ident="root_section">
{chr(10).join(item_xml(q) for q in questions)}
</section>
</assessment>
</questestinterop>
'''
    manifest = f'''<?xml version="1.0" encoding="UTF-8"?>
<manifest identifier="{quiz_id}_manifest" xmlns="http://www.imsglobal.org/xsd/imsccv1p1/imscp_v1p1">
<metadata><schema>IMS Content</schema><schemaversion>1.1.3</schemaversion></metadata>
<organizations/>
<resources>
<resource identifier="{quiz_id}" type="imsqti_xmlv1p2"><file href="{quiz_id}/{quiz_id}.xml"/></resource>
</resources>
</manifest>
'''
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr('imsmanifest.xml', manifest)
        z.writestr(f'{quiz_id}/{quiz_id}.xml', assessment)
    print(f'{len(questions)} questions -> {zip_path}')


if __name__ == '__main__':
    build(sys.argv[1], sys.argv[2], sys.argv[3])
