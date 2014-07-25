from erlport.erlterms import Atom
from paris import __erlang__
import sample
paris_response = __erlang__('paris_response')


def get(_request):
    if sample.ok() is True:
        return paris_response.render_view(Atom('ok'))
    else:
        return paris_response.render_view(Atom('index'))


def post(_request):
    return paris_response.render_view(Atom('index'))


def put(_request):
    return paris_response.render_view(Atom('index'))


def head(_request):
    return paris_response.render_view(Atom('index'))


def delete(_request):
    return paris_response.render_view(Atom('index'))
