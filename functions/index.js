const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Run every hour using HTTP trigger
exports.sendAppointmentReminders = functions.https.onRequest(async (req, res)=>{
  const now = admin.firestore.Timestamp.now();

  try {
    // Query appointments where reminder time is within the next hour
    const snapshot = await admin.firestore()
        .collectionGroup("appointments")
        .where("notificationSent", "==", false)
        .where("reminderTimestamp", "<=", now)
        .get();

    const notifications = [];

    snapshot.forEach((doc) => {
      const appointment = doc.data();

      if (!appointment.fcmToken) return;

      const message = {
        token: appointment.fcmToken,
        notification: {
          title: "Appointment Reminder",
          body: `You have an appointment for 
                    ${appointment.Service} tomorrow at ${appointment.TimeSlot}`,
        },
        data: {
          appointmentId: doc.id,
          type: "appointment_reminder",
        },
      };

      notifications.push(
          // Send the notification
          admin.messaging().send(message)
              .then(() => {
                // Mark notification as sent
                return doc.ref.update({notificationSent: true});
              }),
      );
    });

    await Promise.all(notifications);
    console.log(`Sent ${notifications.length} reminders`);
    res.status(200).send(`Successfully sent ${notifications.length} reminders`);
  } catch (error) {
    console.error("Error sending reminders:", error);
    res.status(500).send(`Error sending reminders: ${error.message}`);
  }
});

// Alternatively, use a Firestore trigger for real-time updates
exports.onAppointmentCreated = functions.firestore
    .document("appointments/{departmentId}/{serviceId}/{appointmentId}")
    .onCreate(async (snap, context) => {
      const appointment = snap.data();

      if (!appointment.fcmToken || appointment.notificationSent) return null;

      try {
        const message = {
          token: appointment.fcmToken,
          notification: {
            title: "Appointment Confirmed",
            body: `Your appointment for ${appointment.Service}
             has been scheduled for ${appointment.TimeSlot}`,
          },
          data: {
            appointmentId: context.params.appointmentId,
            type: "appointment_confirmation",
          },
        };

        await admin.messaging().send(message);
        await snap.ref.update({notificationSent: true});

        console.log("Confirmation notification sent successfully");
        return null;
      } catch (error) {
        console.error("Error sending confirmation:", error);
        return null;
      }
    });
