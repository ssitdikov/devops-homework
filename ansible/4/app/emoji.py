from flask import Flask, request

app = Flask(__name__)


@app.route('/', methods=['POST'])
def emoji():
    if request.method == 'POST':
        request_data = request.get_json()
        word = request_data['word']
        count = request_data['count']

        return '🎲{}'.format(word) * count + '🎲'
    return ''
