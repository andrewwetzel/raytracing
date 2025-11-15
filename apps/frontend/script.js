const sideAInput = document.getElementById('side-a-input');
const sideBInput = document.getElementById('side-b-input');
const calculateButton = document.getElementById('calculate-button');
const hypotenuseResult = document.getElementById('hypotenuse-result');

calculateButton.addEventListener('click', () => {
  const a = sideAInput.value;
  const b = sideBInput.value;

  if (a && b) {
    fetch(`http://127.0.0.1:8000/hypotenuse?a=${a}&b=${b}`)
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
