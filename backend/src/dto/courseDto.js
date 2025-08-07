// Course DTOs for request/response data validation and transformation

export class CreateCourseRequestDto {
  constructor({ name, code, description, instructor, color, schedule }) {
    this.name = name?.trim();
    this.code = code?.toUpperCase().trim();
    this.description = description?.trim();
    this.instructor = instructor?.trim();
    this.color = color || '#2196F3';
    this.schedule = schedule || [];
  }

  validate() {
    const errors = [];

    if (!this.name || this.name.length < 2 || this.name.length > 100) {
      errors.push('Course name must be between 2 and 100 characters');
    }

    if (!this.code || this.code.length < 2 || this.code.length > 20) {
      errors.push('Course code must be between 2 and 20 characters');
    }

    if (this.description && this.description.length > 500) {
      errors.push('Description must not exceed 500 characters');
    }

    if (!this.instructor || this.instructor.length < 2 || this.instructor.length > 100) {
      errors.push('Instructor name must be between 2 and 100 characters');
    }

    if (!this._isValidColor(this.color)) {
      errors.push('Invalid color format. Use hex color (e.g., #2196F3)');
    }

    if (!Array.isArray(this.schedule)) {
      errors.push('Schedule must be an array');
    } else {
      const scheduleErrors = this._validateSchedule(this.schedule);
      errors.push(...scheduleErrors);
    }

    return errors;
  }

  _isValidColor(color) {
    const hexColorRegex = /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/;
    return hexColorRegex.test(color);
  }

  _validateSchedule(schedule) {
    const errors = [];

    for (let i = 0; i < schedule.length; i++) {
      const item = schedule[i];
      const prefix = `Schedule item ${i + 1}:`;

      if (typeof item.dayOfWeek !== 'number' || item.dayOfWeek < 0 || item.dayOfWeek > 6) {
        errors.push(`${prefix} Invalid day of week (must be 0-6)`);
      }

      if (!item.startTime || !item.endTime) {
        errors.push(`${prefix} Start time and end time are required`);
        continue;
      }

      // Validate time format (HH:MM)
      const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
      if (!timeRegex.test(item.startTime)) {
        errors.push(`${prefix} Invalid start time format. Use HH:MM`);
      }

      if (!timeRegex.test(item.endTime)) {
        errors.push(`${prefix} Invalid end time format. Use HH:MM`);
      }

      // Check if start time is before end time
      if (timeRegex.test(item.startTime) && timeRegex.test(item.endTime)) {
        const start = new Date(`2000-01-01T${item.startTime}:00`);
        const end = new Date(`2000-01-01T${item.endTime}:00`);
        if (start >= end) {
          errors.push(`${prefix} Start time must be before end time`);
        }
      }

      if (item.room && item.room.length > 50) {
        errors.push(`${prefix} Room name must not exceed 50 characters`);
      }
    }

    return errors;
  }
}

export class UpdateCourseRequestDto {
  constructor({ name, code, description, instructor, color, schedule }) {
    if (name !== undefined) this.name = name?.trim();
    if (code !== undefined) this.code = code?.toUpperCase().trim();
    if (description !== undefined) this.description = description?.trim();
    if (instructor !== undefined) this.instructor = instructor?.trim();
    if (color !== undefined) this.color = color;
    if (schedule !== undefined) this.schedule = schedule;
  }

  validate() {
    const errors = [];

    if (this.name !== undefined && (!this.name || this.name.length < 2 || this.name.length > 100)) {
      errors.push('Course name must be between 2 and 100 characters');
    }

    if (this.code !== undefined && (!this.code || this.code.length < 2 || this.code.length > 20)) {
      errors.push('Course code must be between 2 and 20 characters');
    }

    if (this.description !== undefined && this.description && this.description.length > 500) {
      errors.push('Description must not exceed 500 characters');
    }

    if (this.instructor !== undefined && (!this.instructor || this.instructor.length < 2 || this.instructor.length > 100)) {
      errors.push('Instructor name must be between 2 and 100 characters');
    }

    if (this.color !== undefined && !this._isValidColor(this.color)) {
      errors.push('Invalid color format. Use hex color (e.g., #2196F3)');
    }

    if (this.schedule !== undefined) {
      if (!Array.isArray(this.schedule)) {
        errors.push('Schedule must be an array');
      } else {
        const scheduleErrors = this._validateSchedule(this.schedule);
        errors.push(...scheduleErrors);
      }
    }

    return errors;
  }

  _isValidColor(color) {
    const hexColorRegex = /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/;
    return hexColorRegex.test(color);
  }

  _validateSchedule(schedule) {
    const errors = [];

    for (let i = 0; i < schedule.length; i++) {
      const item = schedule[i];
      const prefix = `Schedule item ${i + 1}:`;

      if (typeof item.dayOfWeek !== 'number' || item.dayOfWeek < 0 || item.dayOfWeek > 6) {
        errors.push(`${prefix} Invalid day of week (must be 0-6)`);
      }

      if (!item.startTime || !item.endTime) {
        errors.push(`${prefix} Start time and end time are required`);
        continue;
      }

      // Validate time format (HH:MM)
      const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
      if (!timeRegex.test(item.startTime)) {
        errors.push(`${prefix} Invalid start time format. Use HH:MM`);
      }

      if (!timeRegex.test(item.endTime)) {
        errors.push(`${prefix} Invalid end time format. Use HH:MM`);
      }

      // Check if start time is before end time
      if (timeRegex.test(item.startTime) && timeRegex.test(item.endTime)) {
        const start = new Date(`2000-01-01T${item.startTime}:00`);
        const end = new Date(`2000-01-01T${item.endTime}:00`);
        if (start >= end) {
          errors.push(`${prefix} Start time must be before end time`);
        }
      }

      if (item.room && item.room.length > 50) {
        errors.push(`${prefix} Room name must not exceed 50 characters`);
      }
    }

    return errors;
  }
}

export class CourseQueryDto {
  constructor({ page, limit, search, isActive }) {
    this.page = parseInt(page) || 1;
    this.limit = Math.min(parseInt(limit) || 10, 50); // Max 50 items per page
    this.search = search?.trim();
    this.isActive = isActive !== undefined ? Boolean(isActive) : undefined;
  }

  validate() {
    const errors = [];

    if (this.page < 1) {
      errors.push('Page must be greater than 0');
    }

    if (this.limit < 1 || this.limit > 50) {
      errors.push('Limit must be between 1 and 50');
    }

    if (this.search && this.search.length > 100) {
      errors.push('Search term must not exceed 100 characters');
    }

    return errors;
  }
}

// Response DTOs
export class CourseScheduleResponseDto {
  constructor(schedule) {
    this.id = schedule.id;
    this.dayOfWeek = schedule.dayOfWeek;
    this.startTime = schedule.startTime;
    this.endTime = schedule.endTime;
    this.room = schedule.room;
    this.dayName = this._getDayName(schedule.dayOfWeek);
  }

  _getDayName(dayOfWeek) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek] || 'Unknown';
  }
}

export class CourseResponseDto {
  constructor(course) {
    this.id = course.id;
    this.name = course.name;
    this.code = course.code;
    this.description = course.description;
    this.instructor = course.instructor;
    this.color = course.color;
    this.isActive = course.isActive;
    this.createdAt = course.createdAt;
    this.updatedAt = course.updatedAt;

    if (course.schedule) {
      this.schedule = course.schedule.map(s => new CourseScheduleResponseDto(s));
    }

    if (course._count?.attendances !== undefined) {
      this.totalAttendances = course._count.attendances;
    }
  }
}

export class CourseListResponseDto {
  constructor({ courses, pagination }) {
    this.courses = courses.map(course => new CourseResponseDto(course));
    this.pagination = pagination;
  }
}

export class CourseStatsResponseDto {
  constructor({ course, statistics }) {
    this.course = {
      id: course.id,
      name: course.name,
      code: course.code,
    };
    this.statistics = statistics;
  }
} 