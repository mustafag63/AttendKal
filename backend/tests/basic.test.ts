describe('Basic Backend Tests', () => {
    test('Math operations should work', () => {
        expect(1 + 1).toBe(2);
        expect(2 * 3).toBe(6);
    });

    test('String operations should work', () => {
        const testString = 'AttendKal Backend';
        expect(testString.toLowerCase()).toBe('attendkal backend');
        expect(testString.length).toBe(17);
    });

    test('Date operations should work', () => {
        const now = new Date();
        const timestamp = now.getTime();
        const reconstructed = new Date(timestamp);

        expect(reconstructed.getTime()).toBe(now.getTime());
    });

    test('Promise handling should work', async () => {
        const promise = Promise.resolve('test value');
        const result = await promise;

        expect(result).toBe('test value');
    });
});
