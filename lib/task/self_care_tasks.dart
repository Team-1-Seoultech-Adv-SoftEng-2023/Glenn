// tasks/self_care_tasks.dart
import '../fields/self_care_field.dart';
import 'task.dart';
import 'package:uuid/uuid.dart';

final List<Task> selfCareTasks = [
  Task(
    id: const Uuid().v4(),
    name: 'Grab a Coffee',
    description: 'Visit your favorite coffee shop and enjoy a cup of coffee.',
    parentId: '',
    fields: [
      SelfCareField(selfCareActivity: 'Coffee'),
    ],
  ),
  Task(
    id: const Uuid().v4(),
    name: 'Stretch',
    description: 'Take a break and do some stretching exercises.',
    parentId: '',
    fields: [
      SelfCareField(selfCareActivity: 'Stretching'),
    ],
  ),
  Task(
    id: const Uuid().v4(),
    name: 'Drink Water',
    description: 'Stay hydrated by drinking a glass of water.',
    parentId: '',
    fields: [
      SelfCareField(selfCareActivity: 'Water'),
    ],
  ),
  Task(
    id: const Uuid().v4(),
    name: 'Take a Walk',
    description:
        'Go for a short walk to get some fresh air and light exercise.',
    parentId: '',
    fields: [
      SelfCareField(selfCareActivity: 'Walking'),
    ],
  ),
  // Additional self care tasks
  Task(
    id: const Uuid().v4(),
    name: 'Read a Book',
    description: 'Spend some time reading a book of your choice.',
    parentId: '',
    fields: [
      SelfCareField(selfCareActivity: 'Reading'),
    ],
  ),
  Task(
    id: const Uuid().v4(),
    name: 'Listen to Music',
    description: 'Relax and enjoy your favorite music.',
    parentId: '',
    fields: [
      SelfCareField(selfCareActivity: 'Music'),
    ],
  ),
  Task(
    id: const Uuid().v4(),
    name: 'Practice Mindfulness',
    description: 'Take a moment to practice mindfulness and meditation.',
    parentId: '',
    fields: [
      SelfCareField(selfCareActivity: 'Mindfulness'),
    ],
  ),
  Task(
    id: const Uuid().v4(),
    name: 'Cook a Healthy Meal',
    description: 'Try cooking a nutritious and delicious meal.',
    parentId: '',
    fields: [
      SelfCareField(selfCareActivity: 'Cooking'),
    ],
  ),
  Task(
    id: const Uuid().v4(),
    name: 'Write in a Journal',
    description:
        'Reflect on your thoughts and feelings by writing in a journal.',
    parentId: '',
    fields: [
      SelfCareField(selfCareActivity: 'Journaling'),
    ],
  ),
  Task(
    id: const Uuid().v4(),
    name: 'Practice Yoga',
    description:
        'Engage in a yoga session to enhance flexibility and relaxation.',
    parentId: '',
    fields: [
      SelfCareField(selfCareActivity: 'Yoga'),
    ],
  ),
];
