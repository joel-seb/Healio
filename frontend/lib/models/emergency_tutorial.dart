import '../config/video_links.dart';

class EmergencyTutorial {
  final String id;
  final String title;
  final String icon;
  final String color;
  final String urgencyLevel; // Critical, High, Medium
  final String videoUrl; // Placeholder for actual video
  final String videoDuration;
  final List<EmergencyStep> steps;
  final List<String> doList;
  final List<String> dontList;
  final String quickSummary;
  final bool offlineAvailable;
  
  EmergencyTutorial({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.urgencyLevel,
    required this.videoUrl,
    required this.videoDuration,
    required this.steps,
    required this.doList,
    required this.dontList,
    required this.quickSummary,
    this.offlineAvailable = false,
  });
}

class EmergencyStep {
  final int stepNumber;
  final String title;
  final String description;
  final String? imageUrl;
  final bool isCritical;
  
  EmergencyStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.imageUrl,
    this.isCritical = false,
  });
}

// Sample emergency data
class EmergencyData {
  static List<EmergencyTutorial> getEmergencies() {
    return [
      EmergencyTutorial(
        id: '1',
        title: 'CPR & Cardiac Arrest',
        icon: 'favorite',
        color: '0xFFE53935',
        urgencyLevel: 'Critical',
        videoUrl: 'https://www.youtube.com/watch?v=cosVBV96E2g',
        videoDuration: '2:30',
        offlineAvailable: true,
        quickSummary: '1. Check responsiveness\n2. Call 911\n3. Start chest compressions (100-120/min)\n4. Continue until help arrives',
        steps: [
          EmergencyStep(
            stepNumber: 1,
            title: 'Check Responsiveness',
            description: 'Tap the person\'s shoulder firmly and shout "Are you okay?" Check for normal breathing.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 2,
            title: 'Call Emergency Services',
            description: 'Immediately call 911 or ask someone else to call. Put phone on speaker.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 3,
            title: 'Position the Person',
            description: 'Place them on their back on a firm, flat surface. Tilt head back slightly.',
          ),
          EmergencyStep(
            stepNumber: 4,
            title: 'Start Chest Compressions',
            description: 'Place heel of hand on center of chest. Push hard and fast at 100-120 compressions per minute. Go at least 2 inches deep.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 5,
            title: 'Continue CPR',
            description: 'Don\'t stop compressions until professional help arrives or the person shows signs of life.',
            isCritical: true,
          ),
        ],
        doList: [
          'Push hard and fast on the chest',
          'Allow full chest recoil between compressions',
          'Minimize interruptions in compressions',
          'Continue until help arrives',
        ],
        dontList: [
          'Stop compressions unless person revives',
          'Compress over the stomach',
          'Give up - every second counts',
          'Be afraid to help',
        ],
      ),
      EmergencyTutorial(
        id: '2',
        title: 'Severe Bleeding',
        icon: 'bloodtype',
        color: '0xFFD32F2F',
        urgencyLevel: 'Critical',
        videoUrl: 'https://www.youtube.com/watch?v=NxO5LvgqZe0',
        videoDuration: '1:45',
        offlineAvailable: true,
        quickSummary: '1. Apply direct pressure\n2. Elevate wound above heart\n3. Call 911\n4. Keep pressure until help arrives',
        steps: [
          EmergencyStep(
            stepNumber: 1,
            title: 'Ensure Safety',
            description: 'Put on gloves if available. Move person away from danger.',
          ),
          EmergencyStep(
            stepNumber: 2,
            title: 'Apply Direct Pressure',
            description: 'Use clean cloth or gauze. Press firmly on the wound. Don\'t remove it even if blood soaks through - add more layers.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 3,
            title: 'Elevate the Wound',
            description: 'If possible, raise the injured area above the heart level while maintaining pressure.',
          ),
          EmergencyStep(
            stepNumber: 4,
            title: 'Call for Help',
            description: 'Call 911 immediately if bleeding is severe or doesn\'t stop after 10 minutes.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 5,
            title: 'Maintain Pressure',
            description: 'Continue applying firm pressure until emergency responders arrive.',
          ),
        ],
        doList: [
          'Apply firm, direct pressure',
          'Elevate above heart level',
          'Add more layers if blood soaks through',
          'Stay calm and reassure the person',
        ],
        dontList: [
          'Remove the first cloth or bandage',
          'Peek at the wound',
          'Use a tourniquet unless absolutely necessary',
          'Give the person anything to eat or drink',
        ],
      ),
      EmergencyTutorial(
        id: '3',
        title: 'Choking',
        icon: 'cancel_presentation',
        color: '0xFFFF6F00',
        urgencyLevel: 'Critical',
        videoUrl: 'https://www.youtube.com/watch?v=PA9hpOnvtCk',
        videoDuration: '1:30',
        offlineAvailable: true,
        quickSummary: '1. Ask "Are you choking?"\n2. Perform 5 back blows\n3. Perform 5 abdominal thrusts\n4. Repeat until object comes out',
        steps: [
          EmergencyStep(
            stepNumber: 1,
            title: 'Identify Choking',
            description: 'Person can\'t talk, cough, or breathe. They may clutch their throat.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 2,
            title: 'Call for Help',
            description: 'Ask someone to call 911. If alone, perform first aid before calling.',
          ),
          EmergencyStep(
            stepNumber: 3,
            title: 'Give 5 Back Blows',
            description: 'Bend person forward. Strike firmly between shoulder blades with heel of hand.',
          ),
          EmergencyStep(
            stepNumber: 4,
            title: 'Give 5 Abdominal Thrusts',
            description: 'Stand behind, make fist above navel. Grasp fist with other hand and thrust inward and upward sharply.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 5,
            title: 'Repeat Until Clear',
            description: 'Alternate 5 back blows and 5 abdominal thrusts until object is expelled.',
          ),
        ],
        doList: [
          'Act quickly - every second counts',
          'Use firm, quick thrusts',
          'Continue until object is expelled',
          'Seek medical attention afterward',
        ],
        dontList: [
          'Slap the back gently - use force',
          'Give water to drink',
          'Perform on pregnant women - use chest thrusts',
          'Give abdominal thrusts to infants',
        ],
      ),
      EmergencyTutorial(
        id: '4',
        title: 'Burns',
        icon: 'local_fire_department',
        color: '0xFFFF5722',
        urgencyLevel: 'High',
        videoUrl: 'https://www.youtube.com/watch?v=WIfQBIXJtEg',
        videoDuration: '2:00',
        offlineAvailable: true,
        quickSummary: '1. Remove from heat source\n2. Cool with water for 20 minutes\n3. Cover with clean cloth\n4. Seek medical help',
        steps: [
          EmergencyStep(
            stepNumber: 1,
            title: 'Stop the Burning',
            description: 'Move person away from heat source. Remove hot clothing (unless stuck to skin).',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 2,
            title: 'Cool the Burn',
            description: 'Run cool (not cold) water over burn for 20 minutes. Don\'t use ice.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 3,
            title: 'Remove Jewelry',
            description: 'Remove rings, watches, or tight items before swelling starts.',
          ),
          EmergencyStep(
            stepNumber: 4,
            title: 'Cover the Burn',
            description: 'Cover with clean, dry cloth or sterile bandage. Don\'t apply creams or ointments.',
          ),
          EmergencyStep(
            stepNumber: 5,
            title: 'Seek Medical Help',
            description: 'Call 911 for severe burns (larger than 3 inches, on face/hands/joints, or 3rd degree).',
          ),
        ],
        doList: [
          'Cool with running water for 20 minutes',
          'Cover with clean, dry cloth',
          'Elevate burned area if possible',
          'Take pain reliever if needed',
        ],
        dontList: [
          'Apply ice directly',
          'Use butter, oils, or toothpaste',
          'Break blisters',
          'Remove clothing stuck to skin',
        ],
      ),
      EmergencyTutorial(
        id: '5',
        title: 'Snake Bite',
        icon: 'pets',
        color: '0xFF7CB342',
        urgencyLevel: 'High',
        videoUrl: 'https://www.youtube.com/watch?v=3bTBMmjkNDQ',
        videoDuration: '1:40',
        offlineAvailable: false,
        quickSummary: '1. Move away from snake\n2. Keep calm and still\n3. Remove jewelry\n4. Call 911 immediately',
        steps: [
          EmergencyStep(
            stepNumber: 1,
            title: 'Move to Safety',
            description: 'Get away from the snake. Don\'t try to capture or kill it.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 2,
            title: 'Call Emergency Services',
            description: 'Call 911 immediately. Note the snake\'s appearance if safe.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 3,
            title: 'Keep Calm and Still',
            description: 'Stay calm. Keep bitten area below heart level. Limit movement.',
          ),
          EmergencyStep(
            stepNumber: 4,
            title: 'Remove Constricting Items',
            description: 'Remove rings, watches, or tight clothing near bite before swelling starts.',
          ),
          EmergencyStep(
            stepNumber: 5,
            title: 'Mark the Bite',
            description: 'Mark leading edge of swelling with pen. Note time. This helps track progression.',
          ),
        ],
        doList: [
          'Stay calm and still',
          'Keep bite below heart level',
          'Remove jewelry immediately',
          'Note snake\'s appearance safely',
        ],
        dontList: [
          'Try to catch or kill the snake',
          'Apply tourniquets',
          'Cut the wound or suck venom',
          'Apply ice or immerse in water',
        ],
      ),
      EmergencyTutorial(
        id: '6',
        title: 'Fractures & Falls',
        icon: 'healing',
        color: '0xFF5C6BC0',
        urgencyLevel: 'Medium',
        videoUrl: 'https://www.youtube.com/watch?v=oJpVcYBmBnE',
        videoDuration: '2:10',
        offlineAvailable: false,
        quickSummary: '1. Don\'t move the injured area\n2. Immobilize with splint\n3. Apply ice\n4. Seek medical care',
        steps: [
          EmergencyStep(
            stepNumber: 1,
            title: 'Check for Danger',
            description: 'Ensure area is safe. Don\'t move person unless necessary.',
          ),
          EmergencyStep(
            stepNumber: 2,
            title: 'Assess the Injury',
            description: 'Look for deformity, swelling, or severe pain. Check circulation below injury.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 3,
            title: 'Immobilize the Area',
            description: 'Use splint or padding to prevent movement. Include joints above and below fracture.',
          ),
          EmergencyStep(
            stepNumber: 4,
            title: 'Apply Ice',
            description: 'Apply ice pack wrapped in cloth for 15-20 minutes to reduce swelling.',
          ),
          EmergencyStep(
            stepNumber: 5,
            title: 'Get Medical Help',
            description: 'Call 911 or transport to emergency room. Don\'t give food or drink.',
          ),
        ],
        doList: [
          'Immobilize the injured area',
          'Apply ice for swelling',
          'Elevate if possible',
          'Monitor circulation and sensation',
        ],
        dontList: [
          'Try to realign the bone',
          'Move the person unnecessarily',
          'Apply heat',
          'Give anything by mouth if surgery likely',
        ],
      ),
      EmergencyTutorial(
        id: '7',
        title: 'Electric Shock',
        icon: 'bolt',
        color: '0xFFFDD835',
        urgencyLevel: 'Critical',
        videoUrl: 'https://www.youtube.com/watch?v=-kLiAS4kgYg',
        videoDuration: '1:20',
        offlineAvailable: true,
        quickSummary: '1. DON\'T touch the person\n2. Turn off power source\n3. Call 911\n4. Begin CPR if needed',
        steps: [
          EmergencyStep(
            stepNumber: 1,
            title: 'DO NOT Touch',
            description: 'Don\'t touch the person if still in contact with electrical source. You could be shocked too.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 2,
            title: 'Cut the Power',
            description: 'Turn off circuit breaker or remove plug. If can\'t reach, use dry wooden stick to separate person.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 3,
            title: 'Call Emergency Services',
            description: 'Call 911 immediately, even if person seems okay.',
          ),
          EmergencyStep(
            stepNumber: 4,
            title: 'Check Breathing',
            description: 'If not breathing, begin CPR. If breathing, place in recovery position.',
          ),
          EmergencyStep(
            stepNumber: 5,
            title: 'Treat Burns',
            description: 'Cover any burns with sterile bandage. Don\'t apply creams.',
          ),
        ],
        doList: [
          'Turn off power source first',
          'Use non-conductive material to separate',
          'Call 911 immediately',
          'Begin CPR if needed',
        ],
        dontList: [
          'Touch person while connected to power',
          'Use wet materials',
          'Move person unless necessary',
          'Assume person is fine - seek medical help',
        ],
      ),
      EmergencyTutorial(
        id: '8',
        title: 'Stroke',
        icon: 'psychology',
        color: '0xFF9C27B0',
        urgencyLevel: 'Critical',
        videoUrl: 'https://www.youtube.com/watch?v=mkPfNMCOmBA',
        videoDuration: '1:50',
        offlineAvailable: true,
        quickSummary: 'FAST: Face drooping, Arm weakness, Speech difficulty, Time to call 911',
        steps: [
          EmergencyStep(
            stepNumber: 1,
            title: 'Recognize FAST Signs',
            description: 'F-Face drooping, A-Arm weakness, S-Speech difficulty, T-Time to call 911.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 2,
            title: 'Call 911 Immediately',
            description: 'Every minute counts! Call emergency services right away. Note the time symptoms started.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 3,
            title: 'Keep Person Calm',
            description: 'Have person lie down with head slightly elevated. Loosen tight clothing.',
          ),
          EmergencyStep(
            stepNumber: 4,
            title: 'Monitor Condition',
            description: 'Stay with person. Check breathing regularly. Be prepared to do CPR.',
          ),
          EmergencyStep(
            stepNumber: 5,
            title: 'Note Details',
            description: 'Remember when symptoms started and what person was doing. Tell paramedics.',
          ),
        ],
        doList: [
          'Call 911 immediately - time is critical',
          'Note exact time symptoms started',
          'Keep person comfortable',
          'Stay calm and reassuring',
        ],
        dontList: [
          'Give food or drink (aspiration risk)',
          'Let person go to sleep',
          'Drive to hospital yourself',
          'Wait to see if symptoms improve',
        ],
      ),
      EmergencyTutorial(
        id: '9',
        title: 'Seizure',
        icon: 'waves',
        color: '0xFF00897B',
        urgencyLevel: 'High',
        videoUrl: 'https://www.youtube.com/watch?v=4Oy3aSGYxCo',
        videoDuration: '2:00',
        offlineAvailable: true,
        quickSummary: '1. Protect from injury\n2. Turn on side\n3. Time the seizure\n4. Don\'t restrain',
        steps: [
          EmergencyStep(
            stepNumber: 1,
            title: 'Stay Calm',
            description: 'Most seizures stop on their own in 1-2 minutes. Stay calm and time it.',
          ),
          EmergencyStep(
            stepNumber: 2,
            title: 'Protect from Injury',
            description: 'Clear area of hard objects. Cushion head with something soft.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 3,
            title: 'Turn on Side',
            description: 'Gently turn person on their side to keep airway clear.',
          ),
          EmergencyStep(
            stepNumber: 4,
            title: 'Time the Seizure',
            description: 'Call 911 if seizure lasts longer than 5 minutes or person has multiple seizures.',
            isCritical: true,
          ),
          EmergencyStep(
            stepNumber: 5,
            title: 'Stay Until Recovery',
            description: 'Stay with person until fully conscious. Offer reassurance.',
          ),
        ],
        doList: [
          'Time the seizure',
          'Protect head and body from injury',
          'Turn on side when possible',
          'Stay calm and time it',
        ],
        dontList: [
          'Hold person down or restrain',
          'Put anything in their mouth',
          'Give food or water until fully alert',
          'Leave them alone',
        ],
      ),
    ];
  }
}
