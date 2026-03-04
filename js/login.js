// 登录页面交互逻辑

document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('loginForm');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const togglePasswordBtn = document.getElementById('togglePassword');
    const loginBtn = document.getElementById('loginBtn');
    const loginMessage = document.getElementById('loginMessage');
    const emailError = document.getElementById('emailError');
    const passwordError = document.getElementById('passwordError');

    // 切换密码显示/隐藏
    togglePasswordBtn.addEventListener('click', function() {
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
        
        const icon = togglePasswordBtn.querySelector('i');
        icon.classList.toggle('fa-eye');
        icon.classList.toggle('fa-eye-slash');
    });

    // 实时验证 - 邮箱
    emailInput.addEventListener('blur', function() {
        validateEmail();
    });

    emailInput.addEventListener('input', function() {
        if (emailError.textContent) {
            validateEmail();
        }
    });

    // 实时验证 - 密码
    passwordInput.addEventListener('blur', function() {
        validatePassword();
    });

    passwordInput.addEventListener('input', function() {
        if (passwordError.textContent) {
            validatePassword();
        }
    });

    // 验证邮箱
    function validateEmail() {
        const email = emailInput.value.trim();
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        
        if (!email) {
            emailError.textContent = '请输入邮箱';
            return false;
        } else if (!emailRegex.test(email)) {
            emailError.textContent = '请输入有效的邮箱地址';
            return false;
        } else {
            emailError.textContent = '';
            return true;
        }
    }

    // 验证密码
    function validatePassword() {
        const password = passwordInput.value;
        
        if (!password) {
            passwordError.textContent = '请输入密码';
            return false;
        } else if (password.length < 6) {
            passwordError.textContent = '密码至少 6 位';
            return false;
        } else {
            passwordError.textContent = '';
            return true;
        }
    }

    // 模拟登录 API
    function simulateLogin(email, password) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                // 模拟验证：测试账号 test@example.com / 123456
                if (email === 'test@example.com' && password === '123456') {
                    resolve({ success: true, message: '登录成功！欢迎回来' });
                } else {
                    reject({ success: false, message: '邮箱或密码错误' });
                }
            }, 1000);
        });
    }

    // 显示消息
    function showMessage(message, type) {
        loginMessage.textContent = message;
        loginMessage.className = 'login-message ' + type;
        
        // 3 秒后自动隐藏成功消息
        if (type === 'success') {
            setTimeout(() => {
                loginMessage.className = 'login-message';
            }, 3000);
        }
    }

    // 表单提交
    loginForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        // 验证表单
        const isEmailValid = validateEmail();
        const isPasswordValid = validatePassword();
        
        if (!isEmailValid || !isPasswordValid) {
            return;
        }
        
        // 禁用按钮，显示加载状态
        loginBtn.classList.add('loading');
        loginBtn.disabled = true;
        loginMessage.className = 'login-message';
        
        try {
            const result = await simulateLogin(emailInput.value.trim(), passwordInput.value);
            showMessage(result.message, 'success');
            
            // 清空密码
            passwordInput.value = '';
        } catch (error) {
            showMessage(error.message, 'error');
        } finally {
            // 恢复按钮状态
            loginBtn.classList.remove('loading');
            loginBtn.disabled = false;
        }
    });

    // 记住我功能（本地存储）
    const rememberCheckbox = document.getElementById('remember');
    const savedEmail = localStorage.getItem('rememberedEmail');
    
    if (savedEmail) {
        emailInput.value = savedEmail;
        rememberCheckbox.checked = true;
    }
    
    loginForm.addEventListener('submit', function() {
        if (rememberCheckbox.checked) {
            localStorage.setItem('rememberedEmail', emailInput.value.trim());
        } else {
            localStorage.removeItem('rememberedEmail');
        }
    });
});
