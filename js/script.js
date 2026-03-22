// Animate counters
function animateCounters() {
    const counters = document.querySelectorAll('.number');
    counters.forEach(counter => {
        const target = +counter.getAttribute('data-target');
        const increment = target / 100;
        let current = 0;
        const timer = setInterval(() => {
            current += increment;
            if (current >= target) {
                counter.textContent = target;
                clearInterval(timer);
            } else {
                counter.textContent = Math.floor(current);
            }
        }, 30);
    });
}

// Trigger animations on scroll
let countersAnimated = false;

window.addEventListener('scroll', () => {
    const statsSection = document.getElementById('stats');
    if (statsSection) {
        const rect = statsSection.getBoundingClientRect();
        if (!countersAnimated && rect.top < window.innerHeight && rect.bottom > 0) {
            animateCounters();
            countersAnimated = true;
        }
    }
});

// Smooth scrolling
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        document.querySelector(this.getAttribute('href')).scrollIntoView({
            behavior: 'smooth'
        });
    });
});

// Calculator function
function calculate() {
    const weight = parseFloat(document.getElementById('weight').value);
    const height = parseFloat(document.getElementById('height').value);
    const age = parseInt(document.getElementById('age').value);
    const goal = document.getElementById('goal').value;
    if (!weight || !height || !age || !goal) {
        document.getElementById('result').innerText = 'Por favor, completa todos los campos.';
        return;
    }
    const bmi = (weight / ((height / 100) ** 2)).toFixed(2);
    const bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5; // Fórmula básica para hombres
    let calories = bmr;
    if (goal === 'gain') {
        calories += 500;
    } else {
        calories -= 500;
    }
    let result = `Tu IMC es ${bmi}. Calorías recomendadas: ${calories.toFixed(0)} kcal/día. `;
    if (goal === 'gain') {
        result += 'Puedes ganar 5 kg de músculo en 6 meses entrenando en Gym Soca. Plan recomendado: Hipertrofia.';
    } else {
        result += 'Puedes perder grasa en 3-6 meses. Plan recomendado: Fuerza + Cardio.';
    }
    document.getElementById('result').innerText = result;
}

// Store filter functionality
document.addEventListener('DOMContentLoaded', () => {
    const filterButtons = document.querySelectorAll('.filter-btn');
    const cards = document.querySelectorAll('.store .card');

    filterButtons.forEach(button => {
        button.addEventListener('click', () => {
            // Remove active class from all buttons
            filterButtons.forEach(btn => btn.classList.remove('active'));
            // Add active class to clicked button
            button.classList.add('active');

            const filter = button.getAttribute('data-filter');

            cards.forEach(card => {
                if (filter === 'all' || card.getAttribute('data-category') === filter) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        });
    });
});

// Hamburger menu toggle
document.addEventListener('DOMContentLoaded', () => {
    const hamburger = document.getElementById('hamburger');
    const navMenu = document.getElementById('nav-menu');

    if (hamburger && navMenu) {
        hamburger.addEventListener('click', () => {
            navMenu.classList.toggle('active');
        });
    }
});

// Store page section filters
document.addEventListener('DOMContentLoaded', () => {
    const storeFilterButtons = document.querySelectorAll('.store-filter-btn');
    const storeSections = document.querySelectorAll('.product-section');

    if (!storeFilterButtons.length || !storeSections.length) {
        return;
    }

    storeFilterButtons.forEach((button) => {
        button.addEventListener('click', () => {
            const filter = button.getAttribute('data-filter');

            storeFilterButtons.forEach((btn) => btn.classList.remove('active'));
            button.classList.add('active');

            storeSections.forEach((section) => {
                const category = section.getAttribute('data-category');
                if (filter === 'all' || category === filter) {
                    section.style.display = '';
                } else {
                    section.style.display = 'none';
                }
            });
        });
    });
});

// Enrollment form prefill and submit message
document.addEventListener('DOMContentLoaded', () => {
    const registrationForm = document.getElementById('registration-form');
    if (!registrationForm) {
        return;
    }

    const params = new URLSearchParams(window.location.search);
    const planParam = params.get('plan');
    const classParam = params.get('class');

    const membershipPlan = document.getElementById('membershipPlan');
    const classSchedule = document.getElementById('classSchedule');
    const resultBox = document.getElementById('enrollment-result');

    if (planParam && membershipPlan) {
        membershipPlan.value = planParam;
    }

    if (classParam && classSchedule) {
        classSchedule.value = classParam;
    } else if (classSchedule) {
        classSchedule.value = 'No aplica';
    }

    registrationForm.addEventListener('submit', (event) => {
        event.preventDefault();

        const fullName = document.getElementById('fullName');
        const chosenPlan = membershipPlan ? membershipPlan.value : '';
        const chosenClass = classSchedule ? classSchedule.value : 'No aplica';

        if (resultBox) {
            resultBox.textContent = `Inscripcion enviada para ${fullName.value}. Plan: ${chosenPlan}. Clase: ${chosenClass}.`;
        }

        registrationForm.reset();

        if (planParam && membershipPlan) {
            membershipPlan.value = planParam;
        }
        if (classParam && classSchedule) {
            classSchedule.value = classParam;
        } else if (classSchedule) {
            classSchedule.value = 'No aplica';
        }
    });
});

// Android APK auto selector
document.addEventListener('DOMContentLoaded', () => {
    const autoBtn = document.getElementById('auto-download-btn');
    const targetText = document.getElementById('download-target-text');

    if (!autoBtn || !targetText) {
        return;
    }

    autoBtn.href = 'downloads/gymsoca.apk';
    autoBtn.innerHTML = '<i class="fas fa-bolt"></i> Descargar app';
    targetText.textContent = 'Descarga la app de Gymsoca e instalala en tu Android.';
});