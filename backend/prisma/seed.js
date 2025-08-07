import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Starting database seeding...');

    // Clear existing data
    console.log('🧹 Cleaning existing data...');
    await prisma.attendance.deleteMany();
    await prisma.courseSchedule.deleteMany();
    await prisma.course.deleteMany();
    await prisma.subscription.deleteMany();
    await prisma.userSession.deleteMany();
    await prisma.passwordReset.deleteMany();
    await prisma.notification.deleteMany();
    await prisma.user.deleteMany();

    // Create sample users
    console.log('👥 Creating sample users...');

    const users = [
        {
            email: 'student1@attendkal.com',
            password: await bcrypt.hash('password123', 12),
            name: 'Ahmet Yılmaz',
            role: 'STUDENT',
            isActive: true,
            emailVerified: true,
            emailVerifiedAt: new Date(),
        },
        {
            email: 'student2@attendkal.com',
            password: await bcrypt.hash('password123', 12),
            name: 'Fatma Demir',
            role: 'STUDENT',
            isActive: true,
            emailVerified: true,
            emailVerifiedAt: new Date(),
        },
        {
            email: 'teacher@attendkal.com',
            password: await bcrypt.hash('password123', 12),
            name: 'Dr. Mehmet Özkan',
            role: 'TEACHER',
            isActive: true,
            emailVerified: true,
            emailVerifiedAt: new Date(),
        },
        {
            email: 'admin@attendkal.com',
            password: await bcrypt.hash('admin123', 12),
            name: 'Admin User',
            role: 'ADMIN',
            isActive: true,
            emailVerified: true,
            emailVerifiedAt: new Date(),
        },
    ];

    const createdUsers = [];
    for (const userData of users) {
        const user = await prisma.user.create({
            data: userData,
        });
        createdUsers.push(user);
        console.log(`✅ Created user: ${user.email}`);
    }

    // Create subscriptions for users
    console.log('💳 Creating subscriptions...');

    const subscriptions = [
        {
            userId: createdUsers[0].id, // student1 - Free plan
            type: 'FREE',
            isActive: true,
            maxCourses: 2,
        },
        {
            userId: createdUsers[1].id, // student2 - Pro plan
            type: 'PRO',
            isActive: true,
            maxCourses: -1, // unlimited
            endDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year from now
        },
        {
            userId: createdUsers[2].id, // teacher - Premium plan
            type: 'PREMIUM',
            isActive: true,
            maxCourses: -1,
            endDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
        },
        {
            userId: createdUsers[3].id, // admin - Premium plan
            type: 'PREMIUM',
            isActive: true,
            maxCourses: -1,
            endDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
        },
    ];

    for (const subData of subscriptions) {
        const subscription = await prisma.subscription.create({
            data: subData,
        });
        console.log(`✅ Created subscription: ${subscription.type} for user ${subscription.userId}`);
    }

    // Create sample courses
    console.log('📚 Creating sample courses...');

    const courses = [
        {
            userId: createdUsers[0].id, // student1
            name: 'Web Programlama',
            code: 'CS101',
            description: 'Modern web geliştirme teknikleri ve araçları',
            instructor: 'Dr. Ali Veli',
            color: '#2196F3',
            credits: 3,
            semester: 'Güz 2024',
            year: 2024,
            isActive: true,
        },
        {
            userId: createdUsers[0].id, // student1
            name: 'Veri Yapıları',
            code: 'CS102',
            description: 'Temel veri yapıları ve algoritmalar',
            instructor: 'Dr. Ayşe Kaya',
            color: '#4CAF50',
            credits: 4,
            semester: 'Güz 2024',
            year: 2024,
            isActive: true,
        },
        {
            userId: createdUsers[1].id, // student2
            name: 'Mobil Uygulama Geliştirme',
            code: 'CS201',
            description: 'Flutter ve React Native ile mobil uygulama geliştirme',
            instructor: 'Dr. Mehmet Özkan',
            color: '#FF5722',
            credits: 3,
            semester: 'Güz 2024',
            year: 2024,
            isActive: true,
        },
        {
            userId: createdUsers[1].id, // student2
            name: 'Veritabanı Yönetimi',
            code: 'CS202',
            description: 'İlişkisel veritabanları ve SQL',
            instructor: 'Dr. Zeynep Yıldız',
            color: '#9C27B0',
            credits: 3,
            semester: 'Güz 2024',
            year: 2024,
            isActive: true,
        },
        {
            userId: createdUsers[1].id, // student2
            name: 'Yapay Zeka',
            code: 'CS301',
            description: 'Makine öğrenmesi ve yapay zeka teknikleri',
            instructor: 'Prof. Dr. Can Özgür',
            color: '#FF9800',
            credits: 4,
            semester: 'Güz 2024',
            year: 2024,
            isActive: true,
        },
    ];

    const createdCourses = [];
    for (const courseData of courses) {
        const course = await prisma.course.create({
            data: courseData,
        });
        createdCourses.push(course);
        console.log(`✅ Created course: ${course.name} (${course.code})`);
    }

    // Create course schedules
    console.log('📅 Creating course schedules...');

    const schedules = [
        // Web Programlama - Pazartesi ve Çarşamba
        {
            courseId: createdCourses[0].id,
            dayOfWeek: 1, // Monday
            startTime: '09:00',
            endTime: '10:30',
            room: 'A101',
            building: 'Bilgisayar Mühendisliği',
        },
        {
            courseId: createdCourses[0].id,
            dayOfWeek: 3, // Wednesday
            startTime: '09:00',
            endTime: '10:30',
            room: 'A101',
            building: 'Bilgisayar Mühendisliği',
        },
        // Veri Yapıları - Salı ve Perşembe
        {
            courseId: createdCourses[1].id,
            dayOfWeek: 2, // Tuesday
            startTime: '14:00',
            endTime: '15:30',
            room: 'B205',
            building: 'Bilgisayar Mühendisliği',
        },
        {
            courseId: createdCourses[1].id,
            dayOfWeek: 4, // Thursday
            startTime: '14:00',
            endTime: '15:30',
            room: 'B205',
            building: 'Bilgisayar Mühendisliği',
        },
        // Mobil Uygulama Geliştirme - Pazartesi ve Çarşamba
        {
            courseId: createdCourses[2].id,
            dayOfWeek: 1, // Monday
            startTime: '11:00',
            endTime: '12:30',
            room: 'C301',
            building: 'Bilgisayar Mühendisliği',
        },
        {
            courseId: createdCourses[2].id,
            dayOfWeek: 3, // Wednesday
            startTime: '11:00',
            endTime: '12:30',
            room: 'C301',
            building: 'Bilgisayar Mühendisliği',
        },
    ];

    for (const scheduleData of schedules) {
        const schedule = await prisma.courseSchedule.create({
            data: scheduleData,
        });
        console.log(`✅ Created schedule for course ${schedule.courseId}`);
    }

    // Create sample attendance records
    console.log('📊 Creating sample attendance records...');

    const today = new Date();
    const attendanceRecords = [];

    // Generate attendance for the last 30 days
    for (let i = 0; i < 30; i++) {
        const date = new Date(today);
        date.setDate(date.getDate() - i);

        // Skip weekends
        if (date.getDay() === 0 || date.getDay() === 6) continue;

        for (const course of createdCourses) {
            // 80% chance of being present
            const isPresent = Math.random() > 0.2;
            let status = 'PRESENT';

            if (!isPresent) {
                const rand = Math.random();
                if (rand < 0.5) status = 'ABSENT';
                else if (rand < 0.8) status = 'LATE';
                else status = 'EXCUSED';
            }

            attendanceRecords.push({
                userId: course.userId,
                courseId: course.id,
                date: date,
                status: status,
                note: status === 'LATE' ? 'Trafik nedeniyle geç kaldım' :
                    status === 'EXCUSED' ? 'Doktor raporu' : null,
                isVerified: true,
                verifiedAt: new Date(),
            });
        }
    }

    for (const attendanceData of attendanceRecords) {
        await prisma.attendance.create({
            data: attendanceData,
        });
    }
    console.log(`✅ Created ${attendanceRecords.length} attendance records`);

    // Create sample notifications
    console.log('🔔 Creating sample notifications...');

    const notifications = [
        {
            userId: createdUsers[0].id,
            title: 'Hoş Geldiniz!',
            message: 'AttendKal\'a hoş geldiniz! Devam takibi yapmaya başlayabilirsiniz.',
            type: 'SUCCESS',
            isRead: false,
        },
        {
            userId: createdUsers[0].id,
            title: 'Ders Hatırlatması',
            message: 'Web Programlama dersiniz 15 dakika içinde başlayacak.',
            type: 'INFO',
            isRead: true,
            readAt: new Date(),
        },
        {
            userId: createdUsers[1].id,
            title: 'Pro Plan Aktif',
            message: 'Pro planınız başarıyla aktifleştirildi. Artık sınırsız ders ekleyebilirsiniz!',
            type: 'SUCCESS',
            isRead: false,
        },
    ];

    for (const notificationData of notifications) {
        const notification = await prisma.notification.create({
            data: notificationData,
        });
        console.log(`✅ Created notification: ${notification.title}`);
    }

    console.log('✨ Database seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`👥 Users: ${createdUsers.length}`);
    console.log(`📚 Courses: ${createdCourses.length}`);
    console.log(`📅 Schedules: ${schedules.length}`);
    console.log(`📊 Attendance Records: ${attendanceRecords.length}`);
    console.log(`🔔 Notifications: ${notifications.length}`);
    console.log('\n🔑 Test Credentials:');
    console.log('Student 1: student1@attendkal.com / password123 (Free Plan)');
    console.log('Student 2: student2@attendkal.com / password123 (Pro Plan)');
    console.log('Teacher: teacher@attendkal.com / password123');
    console.log('Admin: admin@attendkal.com / admin123');
}

main()
    .catch((e) => {
        console.error('❌ Error during seeding:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    }); 