import csv
import random

subjects = ["Kanji", "Arithmetic", "English", "Science"]
grades = ["Grade 1", "Grade 2"]
units = ["Unit 1", "Unit 2"]

def generate_math():
    if random.random() > 0.5:
        # Generate a fraction problem
        n1, d1 = random.randint(1, 4), random.randint(2, 5)
        n2, d2 = random.randint(1, 4), random.randint(2, 5)
        problem = f"What is |{n1}/{d1}| + |{n2}/{d2}|?"
        answer = f"|{n1*d2 + n2*d1}/{d1*d2}|"
        choices = [answer]
        while len(choices) < 5:
            # Generate plausible fractions
            wn, wd = random.randint(1, 15), random.randint(2, 15)
            w = f"|{wn}/{wd}|"
            if w not in choices: choices.append(w)
    else:
        a = random.randint(1, 20)
        b = random.randint(1, 20)
        op = random.choice(["+", "-"])
        if op == "+":
            ans = a + b
            problem = f"What is {a} + {b}?"
        else:
            if a < b: a, b = b, a
            ans = a - b
            problem = f"What is {a} - {b}?"
        answer = str(ans)
        choices = [answer]
        while len(choices) < 5:
            wrong = ans + random.randint(-5, 5)
            if wrong != ans and wrong >= 0 and str(wrong) not in choices:
                choices.append(str(wrong))
    
    random.shuffle(choices)
    return problem, answer, choices

kanji_db = [
    ("一", "いち", "One"), ("二", "に", "Two"), ("三", "さん", "Three"), 
    ("山", "やま", "Mountain"), ("川", "かわ", "River"), ("田", "た", "Rice Field"), 
    ("日", "ひ", "Sun"), ("月", "つき", "Moon"), ("火", "ひ", "Fire"), ("水", "みず", "Water"),
    ("木", "き", "Tree"), ("金", "かね", "Gold"), ("土", "つち", "Soil"), ("人", "ひと", "Person"),
    ("女", "おんな", "Woman"), ("男", "おとこ", "Man"), ("子", "こ", "Child"), ("大", "おお", "Big"),
    ("小", "ちいさ", "Small"), ("早", "はや", "Early")
]

def generate_kanji(is_mcq=False):
    b, r, m = random.choice(kanji_db)
    problem = f"How do you read _{{{b}}}_(_{r}_)?"
    answer = m
    choices = []
    if is_mcq:
        choices = [m]
        pool = [x[2] for x in kanji_db if x[2] != m]
        choices.extend(random.sample(pool, 4))
        random.shuffle(choices)
    return problem, answer, choices

vocab_db = [
    ("Apple", "りんご", "_{林檎}_(_りんご_)"), 
    ("Banana", "バナナ", "バナナ"), 
    ("Cat", "猫", "_{猫}_(_ねこ_)"), 
    ("Dog", "犬", "_{犬}_(_いぬ_)"),
    ("Sun", "太陽", "_{太陽}_(_たいよう_)"), 
    ("Moon", "月", "_{月}_(_つき_)"),
    ("Water", "水", "_{水}_(_みず_)"),
    ("Fire", "火", "_{火}_(_ひ_)"),
    ("Book", "本", "_{本}_(_ほん_)"),
    ("Car", "車", "_{車}_(_くるま_)")
]

def generate_vocab(is_mcq=False):
    en, jp_plain, jp_ruby = random.choice(vocab_db)
    problem = f"What is '{en}' in Japanese?"
    answer = jp_ruby
    choices = []
    if is_mcq:
        choices = [jp_ruby]
        pool = [x[2] for x in vocab_db if x[2] != jp_ruby]
        choices.extend(random.sample(pool, 4))
        random.shuffle(choices)
    return problem, answer, choices

header = ["id", "type", "subject", "category", "unit", "title", "problem", "answer", "correct_answer", 
          "incorrect_answer_1", "incorrect_answer_2", "incorrect_answer_3", "incorrect_answer_4", 
          "supplement_problem", "supplement_answer", "no_of_times_shown", "no_of_times_attempted", 
          "completion_flag", "need_for_review", "note_1", "note_2"]

rows = []
total_count = 500

for i in range(total_count):
    grade = grades[i % 2]
    unit = units[(i // 2) % 2]
    subject = subjects[random.randint(0, 3)]
    
    # Randomly Choose Classic (1) or MCQ (2)
    q_type = 2 if random.random() > 0.5 else 1
    
    title = f"{subject} Exercise #{i+1}"
    supp_prob = f"Practice session for {subject}."
    supp_ans = "Keep up the good work!"
    
    choices = []
    if subject == "Arithmetic":
        problem, answer, choices = generate_math()
    elif subject == "Kanji":
        problem, answer, choices = generate_kanji(is_mcq=(q_type == 2))
    elif subject == "English":
        problem, answer, choices = generate_vocab(is_mcq=(q_type == 2))
    else: # Science
        problem = f"Science Question {i}: What is the boiling point of water?"
        answer = "100°C"
        choices = ["100°C", "0°C", "50°C", "200°C", "37°C"]
    
    if q_type == 2 and not choices:
         q_type = 1 # Fallback if choices failed to generate

    row = [
        "", # id
        q_type,
        subject,
        grade,
        unit,
        title,
        problem,
        answer,
        answer if q_type == 2 else "",
        choices[0] if q_type == 2 and choices[0] != answer else (choices[1] if q_type == 2 else ""),
        choices[1] if q_type == 2 and choices[1] != answer and len(choices) > 1 else (choices[2] if q_type == 2 and len(choices) > 2 else ""),
        choices[2] if q_type == 2 and choices[2] != answer and len(choices) > 2 else (choices[3] if q_type == 2 and len(choices) > 3 else ""),
        choices[3] if q_type == 2 and choices[3] != answer and len(choices) > 3 else (choices[4] if q_type == 2 and len(choices) > 4 else ""),
        supp_prob,
        supp_ans,
        0, 0, "", "", "", ""
    ]
    # Small fix for incorrects: just take the ones that aren't the answer
    if q_type == 2:
        incorrects = [c for c in choices if c != answer]
        for j in range(4):
            row[9 + j] = incorrects[j] if j < len(incorrects) else "Error Choice"

    rows.append(row)

with open('assets/initial_data.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerows(rows)

print(f"Generated {len(rows)} flashcards in assets/initial_data.csv")
