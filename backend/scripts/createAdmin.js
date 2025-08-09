import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
    const password = 'Admin123!'
    const hash = await bcrypt.hash(password, Number(process.env.BCRYPT_ROUNDS || 12))
    const user = await prisma.user.upsert({
        where: { email: 'admin@attendkal.com' },
        update: { role: 'admin', password: hash },
        create: {
            name: 'Admin',
            email: 'admin@attendkal.com',
            password: hash,
            role: 'admin'
        }
    })
    console.log('✅ Admin ready ->', user.email, '/ Admin123!')
}

main().catch((e) => {
    console.error(e)
    process.exit(1)
}).finally(async () => {
    await prisma.$disconnect()
}) 