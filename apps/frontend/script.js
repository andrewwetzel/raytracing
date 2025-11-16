const sideAInput = document.getElementById('side-a-input');
const sideBInput = document.getElementById('side-b-input');
const calculateButton = document.getElementById('calculate-button');
const hypotenuseResult = document.getElementById('hypotenuse-result');
const triangle = document.querySelector('.triangle');

const updateTriangle = () => {
  const a = sideAInput.value || 0;
  const b = sideBInput.value || 0;

  if (a > 0 && b > 0) {
    const scale = 200 / Math.max(a, b);
    triangle.style.borderBottomWidth = `${a * scale}px`;
    triangle.style.borderLeftWidth = `${b * scale}px`;
  } else {
    triangle.style.borderBottomWidth = `200px`;
    triangle.style.borderLeftWidth = `200px`;
  }
};

sideAInput.addEventListener('input', updateTriangle);
sideBInput.addEventListener('input', updateTriangle);

calculateButton.addEventListener('click', () => {
  const a = sideAInput.value;
  const b = sideBInput.value;

  if (a && b) {
    fetch(`http://backend:8000/hypotenuse?a=${a}&b=${b}`)
      .then(response => response.json())
      .then(data => {
        hypotenuseResult.textContent = data.hypotenuse;
      })
      .catch(error => {
        console.error('Error:', error);
        hypotenuseResult.textContent = 'Error';
      });
  }
});

updateTriangle();
