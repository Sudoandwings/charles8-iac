document.addEventListener("DOMContentLoaded", function() {
    var elements = document.getElementsByClassName("typewrite");
    for (var i = 0; i < elements.length; i++) {
        var toType = JSON.parse(elements[i].getAttribute("data-type"));
        var period = elements[i].getAttribute("data-period");
        if (toType) {
            new Typewriter(elements[i], toType, period);
        }
    }
});

function Typewriter(element, toType, period) {
    this.toType = toType;
    this.element = element;
    this.period = parseInt(period, 10) || 2000;
    this.loopNum = 0;
    this.isDeleting = false;
    this.txt = '';
    this.tick();
}

Typewriter.prototype.tick = function() {
    var currentIndex = this.loopNum % this.toType.length;
    var fullTxt = this.toType[currentIndex];

    if (this.isDeleting) {
        this.txt = fullTxt.substring(0, this.txt.length - 1);
    } else {
        this.txt = fullTxt.substring(0, this.txt.length + 1);
    }

    // Clear existing letters and create UFO effect
    this.element.querySelector('.wrap').innerHTML = '';
    for (let letter of this.txt) {
        const letterSpan = document.createElement('span');
        letterSpan.textContent = letter;
        letterSpan.className = this.isDeleting ? 'release' : 'ufo'; // Assign class for animation
        this.element.querySelector('.wrap').appendChild(letterSpan);
    }

    var delta = 200 - Math.random() * 100; // Typing speed

    if (this.isDeleting) {
        delta /= 2;
    }

    if (!this.isDeleting && this.txt === fullTxt) {
        delta = this.period; // Wait a bit before starting to delete
        this.isDeleting = true;
    } else if (this.isDeleting && this.txt === '') {
        this.isDeleting = false;
        this.loopNum++;
        delta = 500; // Wait a bit before starting to type
    }

    setTimeout(() => this.tick(), delta);
};
