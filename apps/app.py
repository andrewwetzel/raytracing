from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return """
    <h1>Ionospheric Ray Tracing</h1>
    <p>This is a simple web application to simulate the propagation of radio waves through the Earth's ionosphere.</p>
    <p>For more information, please visit the <a href="https://github.com/your-username/raytracing">GitHub repository</a>.</p>
    """

if __name__ == '__main__':
    app.run(debug=True)
