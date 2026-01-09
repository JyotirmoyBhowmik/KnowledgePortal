// SharePoint Knowledge Base Admin Portal
// This is a demo interface - Replace with actual SharePoint REST API calls

class KBAdminPortal {
    constructor() {
        this.siteUrl = '';
        this.connected = false;
        this.init();
    }

    async init() {
        // Initialize portal
        this.setupEventListeners();
        await this.loadConfiguration();
        await this.connectToSharePoint();
        this.updateDashboard();
        this.startAutoRefresh();
    }

    setupEventListeners() {
        // Navigation
        document.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                this.navigate(e.target.getAttribute('href').substring(1));
            });
        });

        // Approval actions
        document.querySelectorAll('.btn-approve').forEach(btn => {
            btn.addEventListener('click', () => this.approveArticle());
        });

        document.querySelectorAll('.btn-reject').forEach(btn => {
            btn.addEventListener('click', () => this.rejectArticle());
        });
    }

    async loadConfiguration() {
        // Load from localStorage or prompt user
        this.siteUrl = localStorage.getItem('kb_site_url') || this.promptForSiteUrl();
    }

    promptForSiteUrl() {
        const url = prompt('Enter your Knowledge Base site URL:', 'https://contoso.sharepoint.com/sites/kb');
        if (url) {
            localStorage.setItem('kb_site_url', url);
            return url;
        }
        return '';
    }

    async connectToSharePoint() {
        this.updateConnectionStatus('Connecting to SharePoint...');

        try {
            // In production, use actual SharePoint REST API or Microsoft Graph API
            // For demo, simulate connection
            await this.delay(1500);

            this.connected = true;
            this.updateConnectionStatus('Connected', true);

            // Hide status after 3 seconds
            setTimeout(() => {
                document.getElementById('connectionStatus').style.opacity = '0';
                setTimeout(() => {
                    document.getElementById('connectionStatus').style.display = 'none';
                }, 300);
            }, 3000);

        } catch (error) {
            console.error('Connection failed:', error);
            this.updateConnectionStatus('Connection failed', false);
        }
    }

    updateConnectionStatus(message, success = null) {
        const statusElement = document.getElementById('connectionStatus');
        const indicator = statusElement.querySelector('.status-indicator');
        const text = statusElement.querySelector('.status-text');

        text.textContent = message;

        if (success === true) {
            indicator.style.background = '#43e97b';
        } else if (success === false) {
            indicator.style.background = '#f5576c';
        } else {
            indicator.style.background = '#ffa500';
        }
    }

    async updateDashboard() {
        // Fetch analytics data
        const stats = await this.fetchAnalytics();

        // Update stat cards
        document.getElementById('totalArticles').textContent = this.formatNumber(stats.totalArticles);
        document.getElementById('totalViews').textContent = this.formatNumber(stats.totalViews);
        document.getElementById('pendingApproval').textContent = stats.pendingApproval;
        document.getElementById('activeContributors').textContent = stats.activeContributors;

        // Update charts
        this.renderUsageChart(stats.usageData);
    }

    async fetchAnalytics() {
        // In production, fetch from SharePoint REST API
        // Example: GET /_api/web/lists/getbytitle('Site Pages')/items

        // Demo data
        return {
            totalArticles: 348,
            totalViews: 12567,
            pendingApproval: 3,
            activeContributors: 24,
            usageData: this.generateMockUsageData()
        };
    }

    generateMockUsageData() {
        const data = [];
        for (let i = 6; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            data.push({
                date: date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
                views: Math.floor(Math.random() * 500) + 1200
            });
        }
        return data;
    }

    renderUsageChart(data) {
        const canvas = document.getElementById('usageChart');
        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        const width = canvas.width = canvas.offsetWidth * 2; // Retina display
        const height = canvas.height = canvas.offsetHeight * 2;
        ctx.scale(2, 2);

        // Simple line chart implementation
        const padding = 40;
        const chartWidth = width / 2 - padding * 2;
        const chartHeight = height / 2 - padding * 2;

        const maxValue = Math.max(...data.map(d => d.views));
        const stepX = chartWidth / (data.length - 1);

        // Draw grid
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)';
        ctx.lineWidth = 1;
        for (let i = 0; i <= 4; i++) {
            const y = padding + (chartHeight / 4) * i;
            ctx.beginPath();
            ctx.moveTo(padding, y);
            ctx.lineTo(width / 2 - padding, y);
            ctx.stroke();
        }

        // Draw line
        ctx.strokeStyle = '#00bcf2';
        ctx.lineWidth = 3;
        ctx.lineJoin = 'round';
        ctx.beginPath();

        data.forEach((point, i) => {
            const x = padding + stepX * i;
            const y = padding + chartHeight - (point.views / maxValue) * chartHeight;

            if (i === 0) {
                ctx.moveTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
        });

        ctx.stroke();

        // Draw points
        data.forEach((point, i) => {
            const x = padding + stepX * i;
            const y = padding + chartHeight - (point.views / maxValue) * chartHeight;

            ctx.fillStyle = '#00bcf2';
            ctx.beginPath();
            ctx.arc(x, y, 4, 0, Math.PI * 2);
            ctx.fill();

            // Draw labels
            ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
            ctx.font = '11px Inter';
            ctx.textAlign = 'center';
            ctx.fillText(point.date, x, height / 2 - padding + 20);
        });
    }

    async approveArticle() {
        // In production, use SharePoint REST API to update item
        // POST /_api/web/lists/getbytitle('Site Pages')/items(id)/approve

        console.log('Article approved');
        this.showNotification('Article approved successfully', 'success');
    }

    async rejectArticle() {
        const reason = prompt('Rejection reason:');
        if (!reason) return;

        console.log('Article rejected:', reason);
        this.showNotification('Article rejected', 'info');
    }

    navigate(view) {
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
        });

        event.target.classList.add('active');

        // In production, show/hide different views
        console.log('Navigate to:', view);
    }

    formatNumber(num) {
        if (num >= 1000000) {
            return (num / 1000000).toFixed(1) + 'M';
        } else if (num >= 1000) {
            return (num / 1000).toFixed(1) + 'K';
        }
        return num.toString();
    }

    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = 'notification';
        notification.style.cssText = `
            position: fixed;
            top: 2rem;
            right: 2rem;
            background: var(--bg-card);
            backdrop-filter: blur(10px);
            border: 1px solid var(--border);
            padding: 1rem 1.5rem;
            border-radius: 12px;
            box-shadow: var(--shadow);
            z-index: 1000;
            animation: slideIn 0.3s ease;
        `;
        notification.textContent = message;
        document.body.appendChild(notification);

        setTimeout(() => {
            notification.style.opacity = '0';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }

    startAutoRefresh() {
        // Refresh dashboard every 60 seconds
        setInterval(() => {
            if (this.connected) {
                this.updateDashboard();
            }
        }, 60000);
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// Initialize portal on DOM load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new KBAdminPortal();
    });
} else {
    new KBAdminPortal();
}

// Export for use in other modules if needed
if (typeof module !== 'undefined' && module.exports) {
    module.exports = KBAdminPortal;
}
