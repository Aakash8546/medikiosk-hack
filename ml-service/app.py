import sys
 
from interviewer import (
    create_empty_history,
    generate_next_question,
    process_patient_answer,
    generate_final_summary
)
from groq_client import AIServiceUnavailableError
 
 
 
 
 
def choose_language():
 
    print()
    print("========================================")
    print("        CLINICAL INTERVIEW AI")
    print("========================================")
    print()
 
    print("Select interview language:")
    print("1. 🇬🇧 English")
    print("2. 🇮🇳 Hindi")
 
    while True:
 
        choice = input(
            "\nEnter choice (1/2): "
        ).strip()
 
        if choice == "1":
 
            print()
            print("✅ Interview language: English")
 
            return "en"
 
        elif choice == "2":
 
            print()
            print("✅ Interview language: Hindi")
 
            return "hi"
 
        else:
 
            print(
                "❌ Invalid choice. Please enter 1 or 2."
            )
 
 
 
def get_patient_answer(language):
 
    while True:
 
        print()
        print("Patient: ", end="")
 
        answer = input().strip()
 
        if answer:
 
            return answer
 
        print()
        print("⚠️ Please provide an answer.")
 
 
 
def ask_ai_question(
    question,
    language
):
 
    if not question:
 
        return
 
    print()
    print("========================================")
    print("🤖 AI:")
    print(question)
    print("========================================")
 
 
 
def show_final_summary(
    history,
    language
):
 
    print()
    print("========================================")
    print("   CLINICAL HISTORY COLLECTION DONE")
    print("========================================")
    print()
 
    try:
 
        print(
            "Generating final clinical summary..."
        )
 
        result = generate_final_summary(
            history,
            language=language
        )
 
        print()
        print("========================================")
        print("        FINAL CLINICAL SUMMARY")
        print("========================================")
        print()

        if result.get("degraded_mode"):

            print(
                "⚠️  NOTE: The AI service was unavailable, so this "
                "summary was auto-generated from the raw collected "
                "data without AI assistance."
            )
            print()
 
        summary = result.get(
            "summary",
            "No summary generated."
        )
 
        print(summary)
 
        print()
        print(
            "Possible Clinical Considerations:"
        )
 
        considerations = result.get(
            "possible_considerations",
            []
        )
 
        if considerations:
 
            for item in considerations:
 
                print(
                    f"- {item}"
                )
 
        else:
 
            print(
                "No considerations generated."
            )
 
        print()
        print("========================================")
 
    except Exception as e:
 
        print()
        print(
            f"❌ Error generating final summary: {e}"
        )
 
 
 
def main():
 
    
    
    
    
 
    language = choose_language()
 
    
    
    
    
 
    history = create_empty_history()
 
    completed_fields = set()
 
    
    
    
    
 
    while True:

        try:

            (
                current_field,
                current_question
            ) = generate_next_question(

                history,

                completed_fields,

                language=language
            )

            break

        except AIServiceUnavailableError:

            
            
            
            print()
            print(
                "⚠️  The AI service is temporarily unavailable "
                "(all API keys/retries exhausted)."
            )

            retry = input(
                "Press Enter to try again, or type 'q' to quit: "
            ).strip().lower()

            if retry == "q":
                return

        except Exception as e:

            print()
            print(
                f"❌ Could not generate first question: {e}"
            )

            return
 
    
    
    
 
    if current_question is None:
 
        print()
        print(
            "AI: Clinical history collection completed."
        )
 
        return
 
    
    
    
    
 
    while current_question is not None:
 
        ask_ai_question(
            current_question,
            language
        )
 
        patient_answer = get_patient_answer(
            language
        )
 
        
        
        
 
        try:
 
            (
                history,
                completed_fields,
                next_question,
                next_field
            ) = process_patient_answer(
 
                patient_answer=patient_answer,
 
                history=history,
 
                completed_fields=completed_fields,
 
                last_question=current_question,
 
                expected_field=current_field,
 
                language=language
            )
 
        except AIServiceUnavailableError:
 
            
            
            
            
            print()
            print("========================================")
            print(
                "⚠️  The AI service is temporarily unavailable."
            )
            print(
                "Your progress so far has NOT been lost -- "
                "please try answering again."
            )
            print("========================================")

            continue

        except Exception as e:
 
            print()
            print("========================================")
            print(
                f"❌ ERROR: {e}"
            )
            print(
                "The interview was stopped safely."
            )
            print("========================================")
 
            return
 
        
        
        
 
        print()
        print("----------------------------------------")
 
        print(
            f"Expected Field: {current_field}"
        )
 
        print(
            f"Completed This Turn: {current_field}"
        )
 
        print("----------------------------------------")
 
        print()
        print("Updated History:")
 
        print(history)
 
        print()
        print("Completed Fields:")
 
        print(completed_fields)
 
        
        
        
 
        if (
            next_question is None
            and history.get("red_flags")
        ):
 
            print()
            print("========================================")
            print("      🚨 INTERVIEW STOPPED FOR SAFETY")
            print("========================================")
 
            print()
            print(
                "A potentially serious warning sign "
                "was detected."
            )

            for flag in history.get("red_flags", []):

                print()
                print(f"  Rule matched: {flag.get('rule')}")
                print(f"  Alert: {flag.get('alert')}")
                print(f"  Matched symptoms: {flag.get('matched_symptoms')}")
 
            print()
            print(
                "Please seek appropriate urgent "
                "medical evaluation."
            )

            print()
            print(
                "(The clinical history collected so far, printed "
                "above as 'Updated History', is preserved -- it "
                "is NOT lost when the interview stops.)"
            )
 
            print()
 
            return
 
        
        
        
 
        if next_question is None:
 
            show_final_summary(
                history,
                language
            )
 
            return
 
        
        
        
 
        current_field = next_field
 
        current_question = next_question
 
 
 
if __name__ == "__main__":
 
    try:
 
        main()
 
    except KeyboardInterrupt:
 
        print()
        print()
        print(
            "Interview cancelled by user."
        )
 
        sys.exit(0)