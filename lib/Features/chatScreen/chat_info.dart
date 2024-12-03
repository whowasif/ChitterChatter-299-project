const info = [
  {
    'name': 'Elon Musk',
    'message': "Let's go on a space trip. Any quiz or mid in next week?",
    'time': '3:53 pm',
    'profilePic':
        'https://upload.wikimedia.org/wikipedia/commons/8/85/Elon_Musk_Royal_Society_%28crop1%29.jpg',
  },
  {
    'name': 'Shadman Khan',
    'message': 'Hello, whats up',
    'time': '2:25 pm',
    'profilePic':
        'https://npr.brightspotcdn.com/dims3/default/strip/false/crop/4000x2667+0+0/resize/1100/quality/85/format/webp/?url=http%3A%2F%2Fnpr-brightspot.s3.amazonaws.com%2F82%2Ffb%2F62f7bcdd47329b5419411e9a7471%2Fbill-gates-portrait-at-npr.jpg',
  },
  {
    'name': 'Naym Hasan',
    'message': 'whats up man!',
    'time': '1:03 pm',
    'profilePic':
        'https://media.wired.com/photos/5c4a1fa640ef432d22a5420f/master/w_1920,c_limit/Culture_GeeksGuide_Bezos.jpg',
  },
  // {
  //   'name': 'Dad',
  //   'message': 'Call me, have some work',
  //   'time': '12:06 pm',
  //   'profilePic':
  //       'https://pbs.twimg.com/profile_images/1419974913260232732/Cy_CUavB.jpg',
  // },
  // {
  //   'name': 'Mom',
  //   'message': 'You ate food?',
  //   'time': '10:00 am',
  //   'profilePic':
  //       'https://uploads.dailydot.com/2018/10/olli-the-polite-cat.jpg?auto=compress%2Cformat&ixlib=php-3.3.0',
  // },
  // {
  //   'name': 'Jurica',
  //   'message': 'Yo!!!!! Long time, no see!?',
  //   'time': '9:53 am',
  //   'profilePic':
  //       'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cmFuZG9tJTIwcGVvcGxlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
  // },
  // {
  //   'name': 'Albert Dera',
  //   'message': 'Am I fat?',
  //   'time': '7:25 am',
  //   'profilePic':
  //       'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8cmFuZG9tJTIwcGVvcGxlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
  // },
  // {
  //   'name': 'Joseph',
  //   'message': 'I am from International Olym...',
  //   'time': '6:02 am',
  //   'profilePic':
  //       'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8cmFuZG9tJTIwcGVvcGxlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
  // },
  // {
  //   'name': 'Sikandar',
  //   'message': 'Lets Code!',
  //   'time': '4:56 am',
  //   'profilePic':
  //       'https://images.unsplash.com/photo-1619194617062-5a61b9c6a049?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHJhbmRvbSUyMHBlb3BsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
  // },
  // {
  //   'name': 'Ian Dooley',
  //   'message': 'Images by Unsplash',
  //   'time': '1:00 am',
  //   'profilePic':
  //       'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8cmFuZG9tJTIwcGVvcGxlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
  // },
];

const messages = [
  {"isMe": false, "text": "Hey What is up with you!!", "time": "10:00 am"},
  {"isMe": true, "text": "im fine,you?", "time": "11:00 am"},
  {"isMe": false, "text": "I am great man!", "time": "11:01 am"},
  {
    "isMe": false,
    "text": "Just messaged cuz long time no contact.",
    "time": "11:01 am"
  },
  {"isMe": true, "text": "ya man", "time": "11:03 am"},
  {
    "isMe": false,
    "text": "check out my the Rocket I built ^^",
    "time": "11:04 am"
  },
  {
    "isMe": true,
    "text": " woaaa! you really kept your word",
    "time": "11:05 am"
  },
  {
    "isMe": false,
    "text": "SpaceX",
    "time": "11:06 am",
  },
  {
    "isMe": true,
    "text": "Sounds great to me!",
    "time": "11:15 am",
  },


  {"isMe": false, "text": "Thanks bro!", "time": "11:17 am"},
  {
    "isMe": false,
    "text": "Did you went to sapce?",
    "time": "11:16 am"
  },
  {
    "isMe": true,
    "text": "No man!",
    "time": "11:17 am"
  },
  {
    "isMe": false,
    "text": "Cool, do you like to?",
    "time": "11:18 am",
  },
  {
    "isMe": true,
    "text": "I would love it?",
    "time": "11:19 am",
  },
  {
    "isMe": false,
    "text": "Let's go on a space trip. Any quiz or mid in next week?",
    "time": "11:20 am",
  },
  {
    "isMe": true,
    "text": "Na re vai, shamne project presentation, demontration. Onek Chape asi",
    "time": "11:22 am",
  },
];