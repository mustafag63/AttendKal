// Authentication DTOs for request/response data validation and transformation

export class RegisterRequestDto {
    constructor({ name, email, password, confirmPassword }) {
        this.name = name?.trim();
        this.email = email?.toLowerCase().trim();
        this.password = password;
        this.confirmPassword = confirmPassword;
    }

    validate() {
        const errors = [];

        if (!this.name || this.name.length < 2 || this.name.length > 50) {
            errors.push('Name must be between 2 and 50 characters');
        }

        if (!this.email || !this._isValidEmail(this.email)) {
            errors.push('Valid email is required');
        }

        if (!this.password || this.password.length < 6) {
            errors.push('Password must be at least 6 characters long');
        }

        if (this.password !== this.confirmPassword) {
            errors.push('Passwords do not match');
        }

        if (!this._isStrongPassword(this.password)) {
            errors.push('Password must contain at least one lowercase letter, one uppercase letter, and one number');
        }

        return errors;
    }

    _isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    _isStrongPassword(password) {
        const strongPasswordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/;
        return strongPasswordRegex.test(password);
    }
}

export class LoginRequestDto {
    constructor({ email, password }) {
        this.email = email?.toLowerCase().trim();
        this.password = password;
    }

    validate() {
        const errors = [];

        if (!this.email || !this._isValidEmail(this.email)) {
            errors.push('Valid email is required');
        }

        if (!this.password) {
            errors.push('Password is required');
        }

        return errors;
    }

    _isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
}

export class UpdatePasswordRequestDto {
    constructor({ currentPassword, newPassword, confirmNewPassword }) {
        this.currentPassword = currentPassword;
        this.newPassword = newPassword;
        this.confirmNewPassword = confirmNewPassword;
    }

    validate() {
        const errors = [];

        if (!this.currentPassword) {
            errors.push('Current password is required');
        }

        if (!this.newPassword || this.newPassword.length < 6) {
            errors.push('New password must be at least 6 characters long');
        }

        if (this.newPassword !== this.confirmNewPassword) {
            errors.push('New passwords do not match');
        }

        if (!this._isStrongPassword(this.newPassword)) {
            errors.push('New password must contain at least one lowercase letter, one uppercase letter, and one number');
        }

        return errors;
    }

    _isStrongPassword(password) {
        const strongPasswordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/;
        return strongPasswordRegex.test(password);
    }
}

export class UpdateProfileRequestDto {
    constructor({ name, avatar }) {
        this.name = name?.trim();
        this.avatar = avatar?.trim();
    }

    validate() {
        const errors = [];

        if (!this.name || this.name.length < 2 || this.name.length > 50) {
            errors.push('Name must be between 2 and 50 characters');
        }

        if (this.avatar && !this._isValidUrl(this.avatar)) {
            errors.push('Avatar must be a valid URL');
        }

        return errors;
    }

    _isValidUrl(url) {
        try {
            new URL(url);
            return true;
        } catch {
            return false;
        }
    }
}

// Response DTOs
export class UserResponseDto {
    constructor(user) {
        this.id = user.id;
        this.email = user.email;
        this.name = user.name;
        this.avatar = user.avatar;
        this.role = user.role;
        this.isActive = user.isActive;
        this.createdAt = user.createdAt;
    }
}

export class AuthResponseDto {
    constructor({ user, token, refreshToken }) {
        this.user = new UserResponseDto(user);
        this.token = token;
        this.refreshToken = refreshToken;
    }
}

export class RefreshTokenRequestDto {
    constructor({ refreshToken }) {
        this.refreshToken = refreshToken;
    }

    validate() {
        const errors = [];

        if (!this.refreshToken) {
            errors.push('Refresh token is required');
        }

        return errors;
    }
} 