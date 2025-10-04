// Система разрешений для админ меню Garry's Mod

class AdminPermissions {
    constructor() {
        this.permissions = {
            // Уровни админов
            levels: {
                'superadmin': {
                    name: 'Супер Админ',
                    color: '#ff6b6b',
                    permissions: ['*'] // Все разрешения
                },
                'admin': {
                    name: 'Админ',
                    color: '#ffa500',
                    permissions: [
                        'player.kick',
                        'player.ban',
                        'player.teleport',
                        'player.spectate',
                        'server.map',
                        'server.weather',
                        'server.time',
                        'admin.commands',
                        'logs.view'
                    ]
                },
                'moderator': {
                    name: 'Модератор',
                    color: '#00ff88',
                    permissions: [
                        'player.kick',
                        'player.teleport',
                        'player.spectate',
                        'logs.view'
                    ]
                },
                'helper': {
                    name: 'Помощник',
                    color: '#3742fa',
                    permissions: [
                        'player.spectate',
                        'logs.view'
                    ]
                }
            },
            
            // Действия с игроками
            playerActions: {
                'kick': {
                    name: 'Кик игрока',
                    permission: 'player.kick',
                    icon: '👢',
                    color: 'warning'
                },
                'ban': {
                    name: 'Бан игрока',
                    permission: 'player.ban',
                    icon: '🚫',
                    color: 'danger'
                },
                'teleport': {
                    name: 'Телепорт к игроку',
                    permission: 'player.teleport',
                    icon: '📍',
                    color: 'info'
                },
                'spectate': {
                    name: 'Наблюдение',
                    permission: 'player.spectate',
                    icon: '👁️',
                    color: 'info'
                }
            },
            
            // Действия с сервером
            serverActions: {
                'map': {
                    name: 'Смена карты',
                    permission: 'server.map',
                    icon: '🗺️',
                    color: 'info'
                },
                'restart': {
                    name: 'Перезапуск сервера',
                    permission: 'server.restart',
                    icon: '🔄',
                    color: 'warning'
                },
                'weather': {
                    name: 'Управление погодой',
                    permission: 'server.weather',
                    icon: '🌤️',
                    color: 'info'
                },
                'time': {
                    name: 'Управление временем',
                    permission: 'server.time',
                    icon: '⏰',
                    color: 'info'
                }
            },
            
            // Админ команды
            adminCommands: {
                'noclip': {
                    name: 'Noclip',
                    permission: 'admin.noclip',
                    command: 'noclip'
                },
                'god': {
                    name: 'Бессмертие',
                    permission: 'admin.god',
                    command: 'god'
                },
                'freeze': {
                    name: 'Заморозить игрока',
                    permission: 'admin.freeze',
                    command: 'freeze'
                },
                'unfreeze': {
                    name: 'Разморозить игрока',
                    permission: 'admin.unfreeze',
                    command: 'unfreeze'
                }
            }
        };
        
        this.currentUser = null;
        this.init();
    }
    
    init() {
        // Загружаем данные текущего пользователя (в реальном проекте с сервера)
        this.loadCurrentUser();
        this.applyPermissions();
    }
    
    loadCurrentUser() {
        // В реальном проекте это будет загружаться с сервера
        this.currentUser = {
            id: 1,
            name: 'AdminUser',
            steamid: 'STEAM_0:1:123456789',
            level: 'superadmin',
            permissions: this.permissions.levels.superadmin.permissions
        };
    }
    
    hasPermission(permission) {
        if (!this.currentUser) return false;
        
        // Супер админ имеет все разрешения
        if (this.currentUser.permissions.includes('*')) return true;
        
        return this.currentUser.permissions.includes(permission);
    }
    
    applyPermissions() {
        // Скрываем/показываем элементы в зависимости от разрешений
        this.updateUI();
        this.updateAdminLevel();
    }
    
    updateUI() {
        // Обновляем кнопки управления игроками
        Object.keys(this.permissions.playerActions).forEach(action => {
            const actionData = this.permissions.playerActions[action];
            const elements = document.querySelectorAll(`[data-action="${action}"]`);
            
            elements.forEach(element => {
                if (this.hasPermission(actionData.permission)) {
                    element.style.display = 'inline-block';
                    element.disabled = false;
                } else {
                    element.style.display = 'none';
                    element.disabled = true;
                }
            });
        });
        
        // Обновляем кнопки управления сервером
        Object.keys(this.permissions.serverActions).forEach(action => {
            const actionData = this.permissions.serverActions[action];
            const elements = document.querySelectorAll(`[data-action="${action}"]`);
            
            elements.forEach(element => {
                if (this.hasPermission(actionData.permission)) {
                    element.style.display = 'inline-block';
                    element.disabled = false;
                } else {
                    element.style.display = 'none';
                    element.disabled = true;
                }
            });
        });
        
        // Обновляем админ команды
        Object.keys(this.permissions.adminCommands).forEach(command => {
            const commandData = this.permissions.adminCommands[command];
            const elements = document.querySelectorAll(`[data-command="${command}"]`);
            
            elements.forEach(element => {
                if (this.hasPermission(commandData.permission)) {
                    element.style.display = 'inline-block';
                    element.disabled = false;
                } else {
                    element.style.display = 'none';
                    element.disabled = true;
                }
            });
        });
    }
    
    updateAdminLevel() {
        const adminLevelElement = document.querySelector('.admin-level');
        if (adminLevelElement && this.currentUser) {
            const levelData = this.permissions.levels[this.currentUser.level];
            adminLevelElement.textContent = levelData.name;
            adminLevelElement.style.background = `linear-gradient(45deg, ${levelData.color}, ${this.adjustColor(levelData.color, -20)})`;
        }
    }
    
    adjustColor(color, amount) {
        const num = parseInt(color.replace("#", ""), 16);
        const r = Math.max(0, Math.min(255, (num >> 16) + amount));
        const g = Math.max(0, Math.min(255, ((num >> 8) & 0x00FF) + amount));
        const b = Math.max(0, Math.min(255, (num & 0x0000FF) + amount));
        return `#${((r << 16) | (g << 8) | b).toString(16).padStart(6, '0')}`;
    }
    
    // Методы для работы с разрешениями
    canKickPlayer() {
        return this.hasPermission('player.kick');
    }
    
    canBanPlayer() {
        return this.hasPermission('player.ban');
    }
    
    canTeleportToPlayer() {
        return this.hasPermission('player.teleport');
    }
    
    canSpectatePlayer() {
        return this.hasPermission('player.spectate');
    }
    
    canChangeMap() {
        return this.hasPermission('server.map');
    }
    
    canRestartServer() {
        return this.hasPermission('server.restart');
    }
    
    canChangeWeather() {
        return this.hasPermission('server.weather');
    }
    
    canChangeTime() {
        return this.hasPermission('server.time');
    }
    
    canExecuteCommand(command) {
        return this.hasPermission('admin.commands') || this.hasPermission('*');
    }
    
    canViewLogs() {
        return this.hasPermission('logs.view');
    }
    
    canEmergencyStop() {
        return this.hasPermission('server.emergency');
    }
    
    canClearProps() {
        return this.hasPermission('server.clearprops');
    }
    
    canResetEconomy() {
        return this.hasPermission('server.reseteconomy');
    }
    
    // Получение информации о текущем пользователе
    getCurrentUser() {
        return this.currentUser;
    }
    
    // Получение уровня пользователя
    getUserLevel() {
        return this.currentUser ? this.currentUser.level : null;
    }
    
    // Получение всех разрешений пользователя
    getUserPermissions() {
        return this.currentUser ? this.currentUser.permissions : [];
    }
    
    // Проверка, является ли пользователь супер админом
    isSuperAdmin() {
        return this.currentUser && this.currentUser.level === 'superadmin';
    }
    
    // Проверка, является ли пользователь админом
    isAdmin() {
        return this.currentUser && ['superadmin', 'admin'].includes(this.currentUser.level);
    }
    
    // Проверка, является ли пользователь модератором
    isModerator() {
        return this.currentUser && ['superadmin', 'admin', 'moderator'].includes(this.currentUser.level);
    }
    
    // Получение списка доступных действий для текущего пользователя
    getAvailableActions() {
        const availableActions = [];
        
        Object.keys(this.permissions.playerActions).forEach(action => {
            const actionData = this.permissions.playerActions[action];
            if (this.hasPermission(actionData.permission)) {
                availableActions.push({
                    type: 'player',
                    action: action,
                    ...actionData
                });
            }
        });
        
        Object.keys(this.permissions.serverActions).forEach(action => {
            const actionData = this.permissions.serverActions[action];
            if (this.hasPermission(actionData.permission)) {
                availableActions.push({
                    type: 'server',
                    action: action,
                    ...actionData
                });
            }
        });
        
        return availableActions;
    }
}

// Система логирования действий админов
class AdminLogger {
    constructor() {
        this.logs = [];
        this.maxLogs = 1000; // Максимальное количество логов в памяти
        this.init();
    }
    
    init() {
        // Загружаем существующие логи (в реальном проекте с сервера)
        this.loadLogs();
    }
    
    loadLogs() {
        // В реальном проекте это будет загружаться с сервера
        this.logs = [
            {
                id: 1,
                timestamp: new Date('2024-01-15T14:30:25'),
                admin: 'AdminUser',
                action: 'player.kick',
                target: 'BadPlayer',
                details: 'Причина: Нарушение правил',
                ip: '192.168.1.100',
                success: true
            },
            {
                id: 2,
                timestamp: new Date('2024-01-15T14:25:10'),
                admin: 'AdminUser',
                action: 'server.map',
                target: 'rp_downtown_v4c_v2',
                details: 'Смена карты',
                ip: '192.168.1.100',
                success: true
            },
            {
                id: 3,
                timestamp: new Date('2024-01-15T14:20:45'),
                admin: 'ModeratorUser',
                action: 'player.teleport',
                target: 'PlayerOne',
                details: 'Телепорт к игроку',
                ip: '192.168.1.101',
                success: true
            }
        ];
    }
    
    log(admin, action, target, details, success = true) {
        const logEntry = {
            id: Date.now(),
            timestamp: new Date(),
            admin: admin,
            action: action,
            target: target,
            details: details,
            ip: this.getClientIP(),
            success: success
        };
        
        this.logs.unshift(logEntry);
        
        // Ограничиваем количество логов в памяти
        if (this.logs.length > this.maxLogs) {
            this.logs = this.logs.slice(0, this.maxLogs);
        }
        
        // В реальном проекте здесь будет отправка на сервер
        this.saveLog(logEntry);
        
        return logEntry;
    }
    
    getClientIP() {
        // В реальном проекте IP будет получаться с сервера
        return '192.168.1.100';
    }
    
    saveLog(logEntry) {
        // В реальном проекте здесь будет отправка на сервер
        console.log('Log saved:', logEntry);
    }
    
    getLogs(filter = {}) {
        let filteredLogs = [...this.logs];
        
        if (filter.admin) {
            filteredLogs = filteredLogs.filter(log => 
                log.admin.toLowerCase().includes(filter.admin.toLowerCase())
            );
        }
        
        if (filter.action) {
            filteredLogs = filteredLogs.filter(log => 
                log.action.includes(filter.action)
            );
        }
        
        if (filter.success !== undefined) {
            filteredLogs = filteredLogs.filter(log => 
                log.success === filter.success
            );
        }
        
        if (filter.dateFrom) {
            filteredLogs = filteredLogs.filter(log => 
                log.timestamp >= new Date(filter.dateFrom)
            );
        }
        
        if (filter.dateTo) {
            filteredLogs = filteredLogs.filter(log => 
                log.timestamp <= new Date(filter.dateTo)
            );
        }
        
        return filteredLogs;
    }
    
    getLogsByAdmin(admin) {
        return this.logs.filter(log => log.admin === admin);
    }
    
    getLogsByAction(action) {
        return this.logs.filter(log => log.action === action);
    }
    
    getRecentLogs(count = 10) {
        return this.logs.slice(0, count);
    }
    
    clearLogs() {
        this.logs = [];
        // В реальном проекте здесь будет очистка на сервере
    }
    
    exportLogs(format = 'json') {
        if (format === 'json') {
            return JSON.stringify(this.logs, null, 2);
        } else if (format === 'csv') {
            return this.convertToCSV(this.logs);
        }
        return this.logs;
    }
    
    convertToCSV(logs) {
        const headers = ['ID', 'Timestamp', 'Admin', 'Action', 'Target', 'Details', 'IP', 'Success'];
        const csvContent = [
            headers.join(','),
            ...logs.map(log => [
                log.id,
                log.timestamp.toISOString(),
                log.admin,
                log.action,
                log.target,
                `"${log.details}"`,
                log.ip,
                log.success
            ].join(','))
        ].join('\n');
        
        return csvContent;
    }
    
    getStats() {
        const stats = {
            totalLogs: this.logs.length,
            successfulActions: this.logs.filter(log => log.success).length,
            failedActions: this.logs.filter(log => !log.success).length,
            uniqueAdmins: [...new Set(this.logs.map(log => log.admin))].length,
            mostCommonAction: this.getMostCommonAction(),
            recentActivity: this.getRecentActivity()
        };
        
        return stats;
    }
    
    getMostCommonAction() {
        const actionCounts = {};
        this.logs.forEach(log => {
            actionCounts[log.action] = (actionCounts[log.action] || 0) + 1;
        });
        
        return Object.keys(actionCounts).reduce((a, b) => 
            actionCounts[a] > actionCounts[b] ? a : b, 'none'
        );
    }
    
    getRecentActivity() {
        const now = new Date();
        const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
        const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        
        return {
            lastHour: this.logs.filter(log => log.timestamp >= oneHourAgo).length,
            lastDay: this.logs.filter(log => log.timestamp >= oneDayAgo).length,
            lastWeek: this.logs.filter(log => 
                log.timestamp >= new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
            ).length
        };
    }
}

// Инициализация систем
const adminPermissions = new AdminPermissions();
const adminLogger = new AdminLogger();

// Экспорт для использования в других файлах
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { AdminPermissions, AdminLogger };
}