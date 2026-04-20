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
            w = f"|{random.randint(1, 10)}/{random.randint(2, 10)}|"
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

def generate_kanji():
    # Placeholder Kanji pairs: (Base, Ruby, Meaning)
    kanji_list = [
        ("一", "いち", "One"), ("二", "に", "Two"), ("三", "さん", "Three"), 
        ("山", "やま", "Mountain"), ("川", "かわ", "River"), ("田", "た", "Rice Field"), 
        ("日", "ひ", "Sun"), ("月", "つき", "Moon"), ("火", "ひ", "Fire"), ("水", "みず", "Water")
    ]
    b, r, m = random.choice(kanji_list)
    return f"How do you read _{{{b}}}_(_{r}_)?", m

def generate_vocab():
    words = [
        ("Apple", "りんご", "_{林檎}_(_りんご_)"), 
        ("Banana", "バナナ", "バナナ"), 
        ("Cat", "猫", "_{猫}_(_ねこ_)"), 
        ("Dog", "犬", "_{犬}_(_いぬ_)"),
        ("Sun", "太陽", "_{太陽}_(_たいよう_)"), 
        ("Moon", "月", "_{月}_(_つき_)")
    ]
    en, jp_plain, jp_ruby = random.choice(words)
    return f"What is '{en}' in Japanese?", jp_ruby

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
    
    # 50/50 Classic vs MCQ
    q_type = 2 if random.random() > 0.5 else 1
    
    title = f"{subject} Exercise #{i+1}"
    supplement_problem = f"Practice session for {subject}."
    supplement_answer = "Keep up the good work!"
    
    if subject == "Arithmetic":
        problem, answer, choices = generate_math()
        if q_type == 2:
            correct = answer
            incorrects = [c for c in choices if c != answer]
            # Ensure we have 4 incorrects
            while len(incorrects) < 4:
                incorrects.append(str(int(answer) + random.randint(10, 20)))
        else:
            correct = ""
            incorrects = ["", "", "", ""]
    elif subject == "Kanji":
        problem, answer = generate_kanji()
        correct = ""
        incorrects = ["", "", "", ""]
        q_type = 1 # Kanji mostly classic for this demo
    else:
        problem, answer = generate_vocab()
        correct = ""
        incorrects = ["", "", "", ""]
        q_type = 1

    row = [
        "", # id
        q_type,
        subject,
        grade,
        unit,
        title,
        problem,
        answer,
        correct if q_type == 2 else "",
        incorrects[0] if q_type == 2 else "",
        incorrects[1] if q_type == 2 else "",
        incorrects[2] if q_type == 2 else "",
        incorrects[3] if q_type == 2 else "",
        supplement_problem,
        supplement_answer,
        0, 0, "", "", "", ""
    ]
    rows.append(row)

with open('assets/initial_data.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerows(rows)

print(f"Generated {len(rows)} flashcards in assets/initial_data.csv")
