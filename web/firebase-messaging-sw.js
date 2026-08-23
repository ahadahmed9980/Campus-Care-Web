// Firebase Messaging service worker for Flutter Web.
// Uses the legacy compat SDK via importScripts (required by firebase_messaging on web).

importScripts('https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js');

// Config from lib/firebase_options.dart → DefaultFirebaseOptions.web
firebase.initializeApp({
  apiKey: 'AIzaSyDfehAvDRIstKpnhAa5_8Z4uPeexX9l1SQ',
  authDomain: 'campuscare-e812f.firebaseapp.com',
  projectId: 'campuscare-e812f',
  storageBucket: 'campuscare-e812f.firebasestorage.app',
  messagingSenderId: '543995537068',
  appId: '1:543995537068:web:6d76896697452f0704a109',
  measurementId: 'G-72X0JMGC77',
});

// Required so FCM can deliver background messages on web.
const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  var notification = payload.notification || {};
  var data = payload.data || {};
  var title = notification.title || data.title || 'Campus Care';
  var options = {
    body: notification.body || data.body || '',
    icon: '/icons/Icon-192.png',
    data: data,
  };

  return self.registration.showNotification(title, options);
});
