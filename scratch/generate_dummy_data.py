import csv

subjects = ['a1', 'a2', 'a3', 'a4']
grades = ['Grade 1', 'Grade 2']
units = ['Unit 1', 'Unit 2']
questions_per_bucket = 40

header = [
    'id', 'type', 'subject', 'category', 'unit', 'title', 'problem', 'answer',
    'correct_answer', 'incorrect_answer_1', 'incorrect_answer_2',
    'incorrect_answer_3', 'incorrect_answer_4', 'supplement_problem',
    'supplement_answer', 'no_of_times_shown', 'no_of_times_attempted',
    'completion_flag', 'need_for_review', 'note_1', 'note_2'
]

data = []
current_id = 1

for sub in subjects:
    for grade in grades:
        for unit in units:
            for i in range(1, questions_per_bucket + 1):
                # Alternate between Flashcard (1) and MCQ (2)
                q_type = 1 if i % 2 != 0 else 2
                title = f"{sub} - {grade} - {unit} - Q{i}"
                problem = f"Dummy problem for {title}"
                
                row = [
                    current_id,
                    q_type,
                    sub,
                    grade,
                    unit,
                    title,
                    problem,
                ]
                
                if q_type == 1:
                    row.extend([f"Answer {i}", "", "", "", "", "", ""])
                else:
                    # MCQ: correct_answer is 'Choice A', incorrects are B, C, D, E
                    row.extend(["", f"Choice A {i}", f"Choice B {i}", f"Choice C {i}", f"Choice D {i}", f"Choice E {i}", ""])
                
                row.extend(["Supp problem", "Supp answer", 0, 0, "", "", "", ""])
                data.append(row)
                current_id += 1

with open('assets/initial_data2.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerows(data)

print(f"Generated {len(data)} questions in assets/initial_data2.csv")
