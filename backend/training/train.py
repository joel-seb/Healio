import spacy
from spacy.training import Example
from spacy.util import minibatch, compounding
import random

# 1. Setup Model
nlp = spacy.blank("en")
if "textcat" not in nlp.pipe_names:
    textcat = nlp.add_pipe("textcat", last=True)
else:
    textcat = nlp.get_pipe("textcat")

labels = ["greeting", "thanks", "disease_prediction", "first_aid", "health_assessment", "unknown"]
for label in labels:
    textcat.add_label(label)

TRAIN_DATA = [
    #greet
    ("hi", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("hello doctor", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("good morning", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("hey there", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("is anyone there?", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("good evening", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("hi bot", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("hello, I need some medical advice", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("hiya", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("good afternoon", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("hey, can you help me?", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("yo", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("greetings", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("hello there", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("morning!", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("I have a question", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("are you online?", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("hi, I'm not feeling well", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("hello, i have a concern", {"cats": {"greeting": 1, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),

    #thanks
    ("thank you", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("thanks a lot", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("I appreciate your help", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("that was very helpful", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("thanks for the info", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("much appreciated", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("you've been great, thanks", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("cheers", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("okay, thanks for clarifying", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("thanks doc", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("thanks, i'll do that", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("that's all I needed, thank you", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("thanks for your time", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("brilliant, thanks", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("thank you so much", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("great advice, thank you", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("you saved me a trip to the hospital, thanks", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),
    ("thanks for explaining everything", {"cats": {"greeting": 0, "thanks": 1, "disease_prediction": 0, "first_aid": 0, "unknown": 0}}),

    #prediction
    ("I have high fever and headache", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I am feeling nausea and vomiting", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("There is yellowing of eyes and dark urine", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("Skin rash and itching are present", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("My throat has been sore since morning", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I can't stop coughing and my chest hurts", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("My stomach is cramping really badly", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I've noticed some red spots on my arms", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I feel very dizzy when I stand up", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("My joints are aching and I feel tired", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I have a persistent runny nose", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("Why is my vision blurry lately?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I'm suffering from diarrhea and dehydration", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I keep sneezing and my eyes are watery", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("There is a sharp pain in my lower back", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I can't taste or smell anything", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("My breathing is very shallow right now", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I have a lump behind my ear", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("My skin feels very dry and scaly", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I have been feeling very weak lately", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I have high fever and headache", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I am feeling nausea and vomiting", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("There is yellowing of eyes and dark urine", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("Skin rash and itching are present", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("My throat has been sore since morning", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I can't stop coughing and my chest hurts", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("My stomach is cramping really badly", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I've noticed some red spots on my arms", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I feel very dizzy when I stand up", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("My joints are aching and I feel tired", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I have a persistent runny nose", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("Why is my vision blurry lately?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I'm suffering from diarrhea and dehydration", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I keep sneezing and my eyes are watery", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("There is a sharp pain in my lower back", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I can't taste or smell anything", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("My breathing is very shallow right now", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I have a lump behind my ear", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("My skin feels very dry and scaly", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),
    ("I have been feeling very weak lately", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 1, "first_aid": 0, "unknown": 0}}),

    #firstaid
    ("What is the first aid for burn injury?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("What should I do immediately for chest pain?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("How do I treat severe bleeding?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("Give me emergency help for fracture", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("How can I stop a nosebleed?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("Steps for CPR please", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("My child swallowed a coin, what do I do?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("Someone is choking, help!", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("How to treat a bee sting?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("What's the procedure for an ankle sprain?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("Emergency care for electric shock", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("How to handle a heat stroke?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("What to do if someone faints?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("How should I clean a deep cut?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("First aid for a dog bite", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("What's the best way to treat a minor burn at home?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("Is there a way to help someone having a seizure?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("I need help with a poison emergency", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),
    ("Tell me how to use an EpiPen", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 1, "unknown": 0}}),

    #unauthorized
    ("What is your name?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("Tell me a joke", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("Who created you?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("What is the weather today?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("How do I cook pasta?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("Who is the president of the USA?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("Can you play some music?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("What is 2 + 2?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("Tell me about the stock market", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("Do you like pizza?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("What's the capital of France?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("Are you a human?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("I want to buy a car", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("What is the meaning of life?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("Tell me a story", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("How do I fix my computer?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("Can you dance?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("What is the latest news?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),
    ("How do I tie a tie?", {"cats": {"greeting": 0, "thanks": 0, "disease_prediction": 0, "first_aid": 0, "unknown": 1}}),

    # health assessment
    ("check my health", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("check my bmi", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("calculate my bmi", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("calculate body mass index", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("calculate my body mass index", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("measure my bmi", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("measure my body mass index", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("check my health metrics", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("show my health metrics", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("analyze my body health", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("analyze my health", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("analyze my vitals", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("check my vitals", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("check my body metrics", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("check my body health", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("calculate health metrics", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("show my bmi", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("can you check my bmi", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("can you calculate my bmi", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("i want to check my bmi", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("i want to analyze my health", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("i want to check my health metrics", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("help me calculate my bmi", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}}),
    ("help me check my health", {"cats": {"greeting":0,"thanks":0,"disease_prediction":0,"first_aid":0,"health_assessment":1,"unknown":0}})
]

random.shuffle(TRAIN_DATA)
split = int(len(TRAIN_DATA) * 0.8)
train_data = TRAIN_DATA[:split]
valid_data = TRAIN_DATA[split:]

def evaluate(nlp, data): 
    correct = 0
    for text, annot in data:
        doc = nlp(text)          
        
        if not doc.cats:
            continue
            
        prediction = max(doc.cats, key=doc.cats.get)
        target = max(annot['cats'], key=annot['cats'].get)
        
        if prediction == target:
            correct += 1
            
    return correct / len(data) if len(data) > 0 else 0

optimizer = nlp.initialize()

print(f"Starting training with {len(train_data)} samples...")
print("-" * 30)

for epoch in range(30): 
    random.shuffle(train_data)
    losses = {}
    
    batches = minibatch(train_data, size=compounding(4.0, 32.0, 1.001))
    
    for batch in batches:
        examples = []
        for text, annotations in batch:
            doc = nlp.make_doc(text)
            examples.append(Example.from_dict(doc, annotations))
        
        nlp.update(examples, sgd=optimizer, drop=0.3, losses=losses)

    val_acc = evaluate(nlp, valid_data)
    print(f"Epoch {epoch+1:2d} | Loss: {losses['textcat']:.4f} | Val Acc: {val_acc:.2%}")

nlp.to_disk("intent_model_v2")
print("-" * 30)
print("Model saved as 'intent_model_v2'")