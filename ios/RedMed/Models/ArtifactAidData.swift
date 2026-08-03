import Foundation

struct ArtifactAidTopic: Identifiable, Hashable {
    let id: String
    let title: String
    let symptoms: [String]
    let care: [String]
}

struct ArtifactAidPane: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let subtitle: String
    let topics: [(label: String, key: String)]
}

let artifactAidPanes: [ArtifactAidPane] = [
    ArtifactAidPane(id: "crash", emoji: "🚗", title: "Crash & Head", subtitle: "Impact · neck · pupils",
                     topics: [("Car Crash", "car-crash"), ("Head & Pupils", "head-pupils")]),
    ArtifactAidPane(id: "bleed", emoji: "🩸", title: "Bleeding", subtitle: "Pressure · tourniquet",
                     topics: [("Find Bleeding", "find-bleeding"), ("Bad Bleeding", "bad-bleeding"),
                              ("Belt Tourniquet", "belt-tourniquet"), ("Gunshot / Stab", "gunshot-stab")]),
    ArtifactAidPane(id: "heart", emoji: "❤️", title: "Heart & Airway", subtitle: "CPR · choking",
                     topics: [("CPR", "cpr"), ("Choking", "choking")]),
    ArtifactAidPane(id: "shock", emoji: "⚡", title: "Shock", subtitle: "Pale · cold · clammy",
                     topics: [("Shock", "shock")]),
    ArtifactAidPane(id: "temp", emoji: "🌡️", title: "Cold & Heat", subtitle: "Notice · warm · cool down",
                     topics: [("Cold (Hypothermia)", "cold-hypothermia"), ("Heat (Exhaustion & Stroke)", "heat-stroke")]),
    ArtifactAidPane(id: "seizure", emoji: "🧠", title: "Seizure", subtitle: "Don't restrain · time it",
                     topics: [("Seizure", "seizure")]),
]

let artifactAidTopics: [String: ArtifactAidTopic] = [
    "car-crash": ArtifactAidTopic(
        id: "car-crash", title: "Car Crash",
        symptoms: ["Impact injury — any speed", "Unresponsive or confused occupant", "Visible bleeding or deformity"],
        care: ["Call 911 — give exact location and number of people", "Turn on hazards. Stay at the scene", "Do NOT move them unless there is fire, rising water, or oncoming traffic", "If you must move: slide them as one unit — never twist the neck", "Control bleeding: press hard with cloth, do not lift to check", "Keep them warm and still until EMS arrives"]
    ),
    "head-pupils": ArtifactAidTopic(
        id: "head-pupils", title: "Head & Pupils",
        symptoms: ["Blow to the head", "Unequal, very large ('blown'), or non-reactive pupils", "Confusion, vomiting, or worsening over minutes"],
        care: ["Call 911 immediately", "Shine a light — pupils should shrink equally; blown or unequal = serious", "Keep head, neck, and spine completely still — do not bend or twist", "Do NOT remove a motorcycle helmet unless the airway is blocked and you are trained", "Watch for deterioration: worsening confusion, repeated vomiting, one pupil larger", "If unconscious but breathing, recovery position only if no spinal injury suspected"]
    ),
    "find-bleeding": ArtifactAidTopic(
        id: "find-bleeding", title: "Find Bleeding",
        symptoms: ["Trauma with clothing on — bleeding may be hidden", "Belly pain, rigidity, or bruising after impact", "Rapidly dropping consciousness"],
        care: ["Call 911 first", "Cut or pull clothing away — expose the entire body to find all wounds", "Press hard on every bleeding source you find", "Check the abdomen in all 4 quadrants — tell 911 exactly where it hurts or is hard", "Internal bleeding cannot be stopped in the field — keep them still and warm"]
    ),
    "bad-bleeding": ArtifactAidTopic(
        id: "bad-bleeding", title: "Bad Bleeding",
        symptoms: ["Blood spurting in pulses (arterial)", "Soaks through cloth in under 1 minute", "Large pool of blood forming"],
        care: ["Call 911 — uncontrolled bleeding kills in minutes", "Press with both hands as hard as you can — your full body weight if needed", "Do NOT lift to check — it restarts clotting. Add more cloth on top if it soaks through", "For a limb: if pressure fails after 3 minutes, apply tourniquet 2–3 inches above the wound", "Wound packing: push cloth into a cavity wound and press hard for a full 3 minutes"]
    ),
    "belt-tourniquet": ArtifactAidTopic(
        id: "belt-tourniquet", title: "Belt Tourniquet",
        symptoms: ["Life-threatening limb bleeding not controlled by direct pressure", "Partial or complete amputation of arm or leg"],
        care: ["Call 911 first — tourniquet is a last resort for limbs only", "Place 2–3 inches above the wound, NOT on a joint", "Tighten until all bleeding stops completely — it will hurt; that is correct", "Note the exact time applied — write it on their skin if possible", "Do NOT loosen or remove until EMS takes over", "Never apply to the neck, chest, or abdomen"]
    ),
    "gunshot-stab": ArtifactAidTopic(
        id: "gunshot-stab", title: "Gunshot / Stab",
        symptoms: ["Penetrating wound to chest, abdomen, neck, or limb", "Sucking chest wound (air noise)", "Rapidly worsening shock"],
        care: ["Call 911 first — scene must be safe before you approach", "Chest wound: seal it on 3 sides with plastic or foil to stop air entry", "Abdomen: do NOT push organs back in. Cover with clean wet cloth", "Limb: pack wound tightly with cloth, apply direct pressure or tourniquet", "Keep victim still and warm. Note time of injury", "Stay on the line with 911 — follow their guidance"]
    ),
    "cpr": ArtifactAidTopic(
        id: "cpr", title: "CPR",
        symptoms: ["Unresponsive — does not react to voice or sternal rub", "No normal breathing (absent or only gasping)", "No pulse felt at neck within 10 seconds"],
        care: ["Call 911 now — put phone on speaker", "Hands-only CPR: heel of hand on center of chest, lock elbows, compress 2–2.4 inches deep", "Rate: 100–120 per minute — push to the beat of 'Stayin' Alive'", "Allow full chest recoil between compressions — do not lean", "Trained? 30 compressions → 2 rescue breaths (1 second each, chest must rise)", "AED: turn it on the moment one is available — follow every prompt"]
    ),
    "choking": ArtifactAidTopic(
        id: "choking", title: "Choking",
        symptoms: ["Cannot speak, cry, or cough forcefully", "High-pitched noise or no sound when breathing", "Clutching throat — universal choking sign"],
        care: ["Ask 'Are you choking?' — if they can cough hard, let them", "If they cannot: stand behind them, lean them forward", "5 firm back blows between shoulder blades with heel of hand", "5 abdominal thrusts (Heimlich): fist above navel, sharp inward-and-upward thrust", "Alternate 5 back blows + 5 thrusts until object is expelled or they go unconscious", "If they become unconscious: lower them to the floor and start CPR — each time you open the airway, look for the object before giving breaths"]
    ),
    "shock": ArtifactAidTopic(
        id: "shock", title: "Shock",
        symptoms: ["Pale, cold, clammy skin", "Rapid weak pulse; rapid shallow breathing", "Confusion, anxiety, or sudden extreme fatigue"],
        care: ["Call 911 — shock is life-threatening", "Lay them flat on their back; elevate legs 12 inches if no spinal or leg injury", "Control any visible bleeding immediately", "Keep them warm — cover with a blanket or clothing", "Do NOT give food or water — aspiration risk", "Do NOT let them walk or sit up", "Talk to them calmly; keep monitoring breathing until EMS arrives"]
    ),
    "cold-hypothermia": ArtifactAidTopic(
        id: "cold-hypothermia", title: "Cold (Hypothermia)",
        symptoms: ["Shivering that has stopped (severe sign)", "Slurred speech, confusion, or stumbling", "Skin is cold to touch; body temp below 95°F (35°C)"],
        care: ["Call 911 — severe hypothermia needs hospital rewarming", "Move them out of the cold gently — rough handling can trigger cardiac arrest", "Remove all wet clothing; replace with dry insulation", "Cover head, neck, and torso first — these lose heat fastest", "Warm slowly: body heat, blankets, warm dry air — no electric blankets or direct heat", "If conscious and able to swallow: warm (not hot) drinks — never alcohol"]
    ),
    "heat-stroke": ArtifactAidTopic(
        id: "heat-stroke", title: "Heat Stroke",
        symptoms: ["Hot skin — may be dry or sweaty", "Confusion, slurred speech, seizure, or unresponsiveness", "Core temperature above 104°F (40°C)"],
        care: ["Call 911 — heat stroke kills; cooling is the emergency treatment", "Move immediately into shade or air conditioning", "Remove excess clothing to expose as much skin as possible", "Cool NOW by any means: ice bath (most effective), cold wet cloths on neck/armpits/groin, fan with misting", "Do NOT give fluids if confused or unresponsive — aspiration risk", "If fully conscious and able to swallow: cold water only — no aspirin or acetaminophen"]
    ),
    "seizure": ArtifactAidTopic(
        id: "seizure", title: "Seizure",
        symptoms: ["Sudden uncontrolled jerking or stiffening", "Loss of consciousness or awareness", "Confusion or sleepiness after jerking stops"],
        care: ["Call 911 if: first seizure, lasts over 5 minutes, no recovery, injury, or pregnant", "Time the seizure from the first moment", "Clear the area — remove hard or sharp objects nearby", "Do NOT hold them down or restrain — you cannot stop it", "Do NOT put anything in their mouth — they cannot swallow their tongue", "Cushion their head with something soft", "After jerking stops: gently roll them onto their side (recovery position) to protect the airway"]
    ),
]
