import puppeteer from 'puppeteer';
import { PDFDocument, rgb } from 'pdf-lib';
import ExcelJS from 'exceljs';
import { prisma } from '../utils/prisma.js';
import { logger } from '../config/logger.js';
import { config } from '../config/index.js';

class ReportService {
  constructor() {
    this.browser = null;
  }

  async initializeBrowser() {
    if (!this.browser) {
      this.browser = await puppeteer.launch({
        headless: 'new',
        args: ['--no-sandbox', '--disable-setuid-sandbox'],
      });
    }
    return this.browser;
  }

  async closeBrowser() {
    if (this.browser) {
      await this.browser.close();
      this.browser = null;
    }
  }

  // Generate comprehensive attendance report
  async generateAttendanceReport(userId, startDate, endDate, options = {}) {
    try {
      const { courseId, format = 'pdf', includeCharts = true } = options;

      // Fetch user data
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { id: true, name: true, email: true },
      });

      if (!user) {
        throw new Error('User not found');
      }

      // Build where clause
      const where = {
        userId,
        date: {
          gte: new Date(startDate),
          lte: new Date(endDate),
        },
        ...(courseId && { courseId }),
      };

      // Fetch attendance data
      const [attendances, courses, summary] = await Promise.all([
        this.getAttendanceData(where),
        this.getCourseData(userId, courseId),
        this.getAttendanceSummary(where),
      ]);

      const reportData = {
        user,
        period: { startDate, endDate },
        attendances,
        courses,
        summary,
        generatedAt: new Date(),
      };

      // Generate report based on format
      switch (format) {
      case 'pdf':
        return await this.generatePDFReport(reportData, includeCharts);
      case 'excel':
        return await this.generateExcelReport(reportData);
      case 'html':
        return await this.generateHTMLReport(reportData);
      default:
        throw new Error(`Unsupported format: ${format}`);
      }
    } catch (error) {
      logger.error('Error generating attendance report:', error);
      throw error;
    }
  }

  async getAttendanceData(where) {
    return prisma.attendance.findMany({
      where,
      include: {
        course: {
          select: {
            id: true,
            name: true,
            code: true,
            color: true,
            instructor: true,
          },
        },
      },
      orderBy: { date: 'desc' },
    });
  }

  async getCourseData(userId, courseId) {
    const where = {
      userId,
      isActive: true,
      ...(courseId && { id: courseId }),
    };

    return prisma.course.findMany({
      where,
      include: {
        schedule: true,
        _count: {
          select: { attendances: true },
        },
      },
    });
  }

  async getAttendanceSummary(where) {
    const stats = await prisma.attendance.groupBy({
      by: ['status'],
      where,
      _count: { status: true },
    });

    const totalClasses = stats.reduce((sum, stat) => sum + stat._count.status, 0);
    const presentCount = stats.find(s => s.status === 'PRESENT')?._count.status || 0;
    const lateCount = stats.find(s => s.status === 'LATE')?._count.status || 0;
    const absentCount = stats.find(s => s.status === 'ABSENT')?._count.status || 0;
    const excusedCount = stats.find(s => s.status === 'EXCUSED')?._count.status || 0;

    const attendedClasses = presentCount + lateCount;
    const attendanceRate = totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0;

    return {
      totalClasses,
      presentCount,
      lateCount,
      absentCount,
      excusedCount,
      attendedClasses,
      attendanceRate: Math.round(attendanceRate * 100) / 100,
    };
  }

  async generatePDFReport(reportData, includeCharts) {
    const htmlContent = this.generateHTMLReport(reportData, includeCharts);

    const browser = await this.initializeBrowser();
    const page = await browser.newPage();

    await page.setContent(htmlContent, { waitUntil: 'networkidle0' });

    const pdfBuffer = await page.pdf({
      format: 'A4',
      printBackground: true,
      margin: {
        top: '20px',
        right: '20px',
        bottom: '20px',
        left: '20px',
      },
    });

    await page.close();

    return {
      buffer: pdfBuffer,
      filename: `attendance-report-${reportData.user.id}-${Date.now()}.pdf`,
      contentType: 'application/pdf',
    };
  }

  generateHTMLReport(reportData, includeCharts = true) {
    const { user, period, attendances, courses, summary, generatedAt } = reportData;

    // Generate charts data if needed
    let chartsHTML = '';
    if (includeCharts) {
      chartsHTML = this.generateChartsHTML(summary, attendances);
    }

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Attendance Report - ${user.name}</title>
        <style>
          body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            margin: 0; 
            padding: 20px; 
            color: #333;
            line-height: 1.6;
          }
          .header { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
            color: white; 
            padding: 30px; 
            border-radius: 10px; 
            text-align: center; 
            margin-bottom: 30px;
          }
          .header h1 { margin: 0; font-size: 2.5em; }
          .header p { margin: 10px 0 0 0; opacity: 0.9; }
          .summary-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
          }
          .summary-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
            border-left: 4px solid #667eea;
          }
          .summary-card h3 { margin: 0 0 10px 0; color: #667eea; }
          .summary-card .value { font-size: 2em; font-weight: bold; color: #333; }
          .summary-card .label { color: #666; font-size: 0.9em; }
          .section { 
            background: white; 
            padding: 25px; 
            margin-bottom: 20px; 
            border-radius: 10px; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          }
          .section h2 { 
            margin-top: 0; 
            color: #667eea; 
            border-bottom: 2px solid #667eea; 
            padding-bottom: 10px; 
          }
          table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-top: 15px; 
          }
          th, td { 
            padding: 12px; 
            text-align: left; 
            border-bottom: 1px solid #ddd; 
          }
          th { 
            background: #f8f9fa; 
            font-weight: 600; 
            color: #333;
          }
          .status-present { color: #28a745; font-weight: bold; }
          .status-absent { color: #dc3545; font-weight: bold; }
          .status-late { color: #ffc107; font-weight: bold; }
          .status-excused { color: #6c757d; font-weight: bold; }
          .footer { 
            text-align: center; 
            color: #666; 
            font-size: 0.9em; 
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
          }
          .charts-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
          }
          .chart-container {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          }
          @media print {
            body { margin: 0; }
            .summary-cards { grid-template-columns: repeat(2, 1fr); }
            .charts-section { grid-template-columns: 1fr; }
          }
        </style>
        ${includeCharts ? '<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>' : ''}
      </head>
      <body>
        <div class="header">
          <h1>📊 Attendance Report</h1>
          <p>${user.name} • ${period.startDate} to ${period.endDate}</p>
        </div>

        <div class="summary-cards">
          <div class="summary-card">
            <h3>Attendance Rate</h3>
            <div class="value">${summary.attendanceRate}%</div>
            <div class="label">Overall Performance</div>
          </div>
          <div class="summary-card">
            <h3>Classes Attended</h3>
            <div class="value">${summary.attendedClasses}</div>
            <div class="label">out of ${summary.totalClasses}</div>
          </div>
          <div class="summary-card">
            <h3>Present</h3>
            <div class="value">${summary.presentCount}</div>
            <div class="label">On Time</div>
          </div>
          <div class="summary-card">
            <h3>Late</h3>
            <div class="value">${summary.lateCount}</div>
            <div class="label">Arrived Late</div>
          </div>
        </div>

        ${chartsHTML}

        <div class="section">
          <h2>📚 Course Overview</h2>
          <table>
            <thead>
              <tr>
                <th>Course</th>
                <th>Instructor</th>
                <th>Total Classes</th>
                <th>Schedule</th>
              </tr>
            </thead>
            <tbody>
              ${courses.map(course => `
                <tr>
                  <td>
                    <strong style="color: ${course.color};">${course.name}</strong><br>
                    <small>${course.code}</small>
                  </td>
                  <td>${course.instructor}</td>
                  <td>${course._count.attendances}</td>
                  <td>
                    ${course.schedule.map(s => `
                      ${this.getDayName(s.dayOfWeek)} ${s.startTime}-${s.endTime}
                    `).join('<br>')}
                  </td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>

        <div class="section">
          <h2>📋 Attendance Records</h2>
          <table>
            <thead>
              <tr>
                <th>Date</th>
                <th>Course</th>
                <th>Status</th>
                <th>Note</th>
              </tr>
            </thead>
            <tbody>
              ${attendances.map(attendance => `
                <tr>
                  <td>${new Date(attendance.date).toLocaleDateString()}</td>
                  <td>
                    <strong style="color: ${attendance.course.color};">
                      ${attendance.course.name}
                    </strong><br>
                    <small>${attendance.course.code}</small>
                  </td>
                  <td>
                    <span class="status-${attendance.status.toLowerCase()}">
                      ${attendance.status}
                    </span>
                  </td>
                  <td>${attendance.note || '-'}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>

        <div class="footer">
          <p>Generated on ${generatedAt.toLocaleString()} by AttendKal</p>
          <p>© ${new Date().getFullYear()} AttendKal - Smart Attendance Tracking</p>
        </div>

        ${includeCharts ? this.generateChartsScript(summary, attendances) : ''}
      </body>
      </html>
    `;
  }

  generateChartsHTML(summary, attendances) {
    return `
      <div class="charts-section">
        <div class="chart-container">
          <h3>Attendance Distribution</h3>
          <canvas id="attendanceChart" width="400" height="200"></canvas>
        </div>
        <div class="chart-container">
          <h3>Weekly Trend</h3>
          <canvas id="trendChart" width="400" height="200"></canvas>
        </div>
      </div>
    `;
  }

  generateChartsScript(summary, attendances) {
    // Prepare weekly trend data
    const weeklyData = this.prepareWeeklyTrendData(attendances);

    return `
      <script>
        // Attendance Distribution Chart
        const ctx1 = document.getElementById('attendanceChart').getContext('2d');
        new Chart(ctx1, {
          type: 'doughnut',
          data: {
            labels: ['Present', 'Late', 'Absent', 'Excused'],
            datasets: [{
              data: [${summary.presentCount}, ${summary.lateCount}, ${summary.absentCount}, ${summary.excusedCount}],
              backgroundColor: ['#28a745', '#ffc107', '#dc3545', '#6c757d']
            }]
          },
          options: {
            responsive: true,
            plugins: {
              legend: {
                position: 'bottom'
              }
            }
          }
        });

        // Weekly Trend Chart
        const ctx2 = document.getElementById('trendChart').getContext('2d');
        new Chart(ctx2, {
          type: 'line',
          data: {
            labels: ${JSON.stringify(weeklyData.labels)},
            datasets: [{
              label: 'Attendance Rate %',
              data: ${JSON.stringify(weeklyData.rates)},
              borderColor: '#667eea',
              backgroundColor: 'rgba(102, 126, 234, 0.1)',
              tension: 0.4
            }]
          },
          options: {
            responsive: true,
            scales: {
              y: {
                beginAtZero: true,
                max: 100
              }
            }
          }
        });
      </script>
    `;
  }

  prepareWeeklyTrendData(attendances) {
    // Group attendances by week and calculate rates
    const weeks = {};

    attendances.forEach(attendance => {
      const date = new Date(attendance.date);
      const weekStart = new Date(date.setDate(date.getDate() - date.getDay()));
      const weekKey = weekStart.toISOString().split('T')[0];

      if (!weeks[weekKey]) {
        weeks[weekKey] = { total: 0, attended: 0 };
      }

      weeks[weekKey].total++;
      if (attendance.status === 'PRESENT' || attendance.status === 'LATE') {
        weeks[weekKey].attended++;
      }
    });

    const labels = Object.keys(weeks).sort();
    const rates = labels.map(week => {
      const data = weeks[week];
      return data.total > 0 ? Math.round((data.attended / data.total) * 100) : 0;
    });

    return { labels, rates };
  }

  async generateExcelReport(reportData) {
    const { user, period, attendances, courses, summary, generatedAt } = reportData;

    const workbook = new ExcelJS.Workbook();

    // Summary Sheet
    const summarySheet = workbook.addWorksheet('Summary');

    // Add header
    summarySheet.mergeCells('A1:E1');
    summarySheet.getCell('A1').value = `Attendance Report - ${user.name}`;
    summarySheet.getCell('A1').font = { size: 16, bold: true };
    summarySheet.getCell('A1').alignment = { horizontal: 'center' };

    // Add period info
    summarySheet.getCell('A3').value = 'Period:';
    summarySheet.getCell('B3').value = `${period.startDate} to ${period.endDate}`;
    summarySheet.getCell('A4').value = 'Generated:';
    summarySheet.getCell('B4').value = generatedAt.toLocaleString();

    // Add summary statistics
    summarySheet.getCell('A6').value = 'Attendance Summary';
    summarySheet.getCell('A6').font = { bold: true };

    const summaryData = [
      ['Metric', 'Value'],
      ['Total Classes', summary.totalClasses],
      ['Classes Attended', summary.attendedClasses],
      ['Attendance Rate', `${summary.attendanceRate}%`],
      ['Present', summary.presentCount],
      ['Late', summary.lateCount],
      ['Absent', summary.absentCount],
      ['Excused', summary.excusedCount],
    ];

    summarySheet.addRows(summaryData, 'A7');

    // Attendance Details Sheet
    const detailsSheet = workbook.addWorksheet('Attendance Details');

    const headers = ['Date', 'Course Name', 'Course Code', 'Status', 'Note'];
    detailsSheet.addRow(headers);

    const attendanceRows = attendances.map(attendance => [
      attendance.date.toLocaleDateString(),
      attendance.course.name,
      attendance.course.code,
      attendance.status,
      attendance.note || '',
    ]);

    detailsSheet.addRows(attendanceRows);

    // Style the headers
    detailsSheet.getRow(1).font = { bold: true };
    detailsSheet.getRow(1).fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFE0E0E0' },
    };

    // Auto-fit columns
    detailsSheet.columns.forEach(column => {
      column.width = 15;
    });

    const buffer = await workbook.xlsx.writeBuffer();

    return {
      buffer,
      filename: `attendance-report-${user.id}-${Date.now()}.xlsx`,
      contentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    };
  }

  getDayName(dayOfWeek) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dayOfWeek] || 'Unknown';
  }

  // Cleanup method
  async cleanup() {
    await this.closeBrowser();
  }
}

// Export singleton instance
export const reportService = new ReportService();
export const generateAttendanceReport = reportService.generateAttendanceReport.bind(reportService);
export default reportService;

// Graceful shutdown
process.on('SIGTERM', async () => {
  await reportService.cleanup();
});

process.on('SIGINT', async () => {
  await reportService.cleanup();
}); 