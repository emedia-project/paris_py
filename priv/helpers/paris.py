import erlport.erlterms
import erlport.erlang

erl_modules = {}


# from paris import __erlang__
# lists = __erlang__('lists')
# lists.sum([1, 2, 3])
def __erlang__(name):

    def __getattr__(self, name):
        def wrapper(*args, **kwargs):
            return erlport.erlang.call(
                erlport.erlterms.Atom(self.__class__.__name__),
                erlport.erlterms.Atom(name), list(args))
        return wrapper

    if name in erl_modules:
        return erl_modules[name]
    else:
        Klass = type(name, (object,), {'__getattr__': __getattr__})
        klass = Klass()
        erl_modules[name] = klass
        return klass
