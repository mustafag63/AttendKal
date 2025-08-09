import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
    const email = 'admin@attendkal.com'
    const plain = 'Admin123!'
    const hash = await bcrypt.hash(plain, 12)

    await prisma.user.upsert({
        where: { email },
        update: { role: 'ADMIN', password: hash },
        create: {
            name: 'Admin',
            email,
            password: hash,
            role: 'ADMIN',
        }
    })

    console.log('✅ Admin ready ->', email, '/ Admin123!')
}

main().catch((e) => {
    console.error(e)
    process.exit(1)
}).finally(async () => {
    await prisma.$disconnect()
}) 