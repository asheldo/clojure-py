cimport clojure.lang.polymorphic as poly
from clojure.lang.polymorphic import extend
import array as _array
import cython as cython


cdef class Unset(object):
    pass

unset = Unset()


class ArityException(Exception):
    def __init__(self, arity):
        Exception.__init__("Wrong number of args, got "+ str(len(arity)))


def is_identical(x, y):
    return x is y

def is_nil(x):
    return x is None

def is_array(x):
    return x is list

def is_number(x):
    return isinstance(x, int) or isinstance(x, float)

def is_some(x):
    return x is not None


## arrays

def make_array(*args):
    if len(args) == 1:
        return [None] * args[0]
    elif len(args) == 2:
        tp = args[0]
        size = args[1]

        return [None] * size

        ## TODO: add typed arrays
        #if isinstance(tp, str):
        #    return _array.array(tp)

def array(*args):
    return list(args)

def aclone(array):
    return array[:]

def aget(array, idx, *idxs):
    if len(idxs) == 1:
        return array[idx]
    elif len(idxs) > 1:
        return aget(array[idx], *idxs)

def aset(array, i, val, *more):
    if len(more) == 0:
        array[i] = val
        return array
    elif len(more) > 0:
        return aset(aget(array, i), val, *more)

def alength(array):
    return len(array)

## Forward Declaration
def reduce():
    pass

def _lst_append(lst, v):
    lst.append(v)
    return lst

def into_array(*args):
    if len(args) == 1:
        return reduce(_lst_append, array(), args[0])
    elif len(args) == 2:
        return reduce(_lst_append, make_array(args[0], 0), args[1])
    else:
        raise ArityException(args)




def reduce(f, init, coll):
    acc = init
    for x in coll:
        acc = f(acc, x)
    return acc


### Core Protocols


IClonable = poly.Protocol("ICloneable")
_clone = poly.PolymorphicFn(IClonable, "-clone")


ICounted = poly.Protocol("ICounted")
_count = poly.PolymorphicFn(ICounted, "-count")
count = _count

IEmptyableCollection = poly.Protocol("IEmptyableCollection")
_empty = poly.PolymorphicFn(IEmptyableCollection, "-empty")

ICollection = poly.Protocol("ICollection")
_conj = poly.PolymorphicFn(ICollection, "-conj")
conj = _conj

IIndexed = poly.Protocol("IIndexed")
_nth = poly.PolymorphicFn(IIndexed, "-nth")

def nth(coll, n, not_found = None):
    return _nth(coll, n, not_found)

ASeq = poly.Protocol("ASeq")

ISeq = poly.Protocol("ISeq")
_first = poly.PolymorphicFn(ISeq, "-first")
_first.extend(type(None), lambda x: x)

_rest = poly.PolymorphicFn(ISeq, "-rest")
_rest.extend(type(None), lambda x: x)

first = _first
rest = _rest


_first.set_default(lambda x: _first(_seq(x)))
_rest.set_default(lambda x: _rest(_seq(x)))

INext = poly.Protocol("INext")
_next = poly.PolymorphicFn(INext, "-next")
_next.extend(type(None), lambda x: x)


next = _next

ILookup = poly.Protocol("ILookup")
_lookup = poly.PolymorphicFn(ILookup, "-lookup")

IAssociative = poly.Protocol("IAssociative")
_assoc = poly.PolymorphicFn(IAssociative, "-assoc")
_contains_key = poly.PolymorphicFn(IAssociative, "-contains-key?")

IMap = poly.Protocol("IMap")
_dissoc = poly.PolymorphicFn(IMap, "-dissoc")

IMapEntry = poly.Protocol("IMapEntry")
_key = poly.PolymorphicFn(IMapEntry, "-key")
_val = poly.PolymorphicFn(IMapEntry, "-val")

ISet = poly.Protocol("ISet")
_disjoin = poly.PolymorphicFn(ISet, "-disjoin")

IStack = poly.Protocol("IStack")
_peek = poly.PolymorphicFn(IStack, "-peek")
_pop = poly.PolymorphicFn(IStack, "-pop")

IVector = poly.Protocol("IVector")
_assoc_n = poly.PolymorphicFn(IVector, "-assoc-n")

IDeref = poly.Protocol("IDeref")
_deref = poly.PolymorphicFn(IDeref, "-deref")
deref = _deref

IDerefWithTimeout = poly.Protocol("IDerefWithTimeout")
_deref_with_timeout = poly.PolymorphicFn(IDerefWithTimeout, "-deref-with-timeout")

IMeta = poly.Protocol("IMeta")
_meta = poly.PolymorphicFn(IMeta, "-meta")
_meta.set_default(lambda *args: None)


IWithMeta = poly.Protocol("IWithMeta")
_with_meta = poly.PolymorphicFn(IMeta, "-with-meta")

IReduce = poly.Protocol("IReduce")
_reduce = poly.PolymorphicFn(IReduce, "-reduce")

def reduce(f, val, coll = unset):
    if coll is unset:
        return _reduce(val, coll)
    return _reduce(coll, f, val)

IKVReduce = poly.Protocol("IKVReduce")
_kv_reduce = poly.PolymorphicFn(IReduce, "-kv-reduce")

IEquiv = poly.Protocol("IEquiv")
_equiv = poly.PolymorphicFn(IEquiv, "-equiv")
_equiv.set_default(lambda x, y: x == y)
equiv = _equiv

IFn = poly.Protocol("IFn")
_invoke = poly.PolymorphicFn(IFn, "-invoke")

IHash = poly.Protocol("IHash")
_hash = poly.PolymorphicFn(IHash, "-hash")

ISeqable = poly.Protocol("ISeqable")
_seq = poly.PolymorphicFn(ISeqable, "-seq")

ISequential = poly.Protocol("ISequential")

ISeqable = poly.Protocol("ISeqable")
_seq = poly.PolymorphicFn(ISeqable, "-seq")

seq = _seq


IList = poly.Protocol("IList")
IRecord = poly.Protocol("IRecord")

IReversable = poly.Protocol("IReversable")
_rseq = poly.PolymorphicFn(ISeqable, "-rseq")

IWriter = poly.Protocol("IWriter")
_write = poly.PolymorphicFn(IWriter, "-write")
_flush = poly.PolymorphicFn(IWriter, "-flush")

INamed = poly.Protocol("INamed")
_name = poly.PolymorphicFn(INamed, "-name")
_namespace = poly.PolymorphicFn(INamed, "-namespace")
name = _name
namespace = _namespace




### Hashing Stuff

#unsigned int rotl(unsigned int value, int shift) {
#    return (value << shift) | (value >> (sizeof(value) * CHAR_BIT - shift));
#}

#unsigned int rotr(unsigned int value, int shift) {
#    return (value >> shift) | (value << (sizeof(value) * CHAR_BIT - shift));
#}

ctypedef unsigned int uint

cdef uint m3_seed = 0
cdef uint m3_c1 = 0xcc9e2d51
cdef uint m3_c2 = 0x1b873593

@cython.overflowcheck(False)
cdef uint __rotl(uint value, uint shift):
    return (value << shift) | (value >> (sizeof(uint) * 8 - shift))

@cython.overflowcheck(False)
cdef uint __rotr(uint value, uint shift):
    return (value >> shift) | (value << (sizeof(uint) * 8 - shift))

@cython.overflowcheck(False)
cdef uint m3_mix_K1(uint k1):
    return m3_c2 *__rotl(m3_c1 * k1, 15)

@cython.overflowcheck(False)
cdef uint m3_mix_H1(uint h1, uint k1):
    return (5 * __rotl(h1 ^ k1, 13)) + <uint>0xe6546b64

@cython.overflowcheck(False)
cdef uint m3_fmix(uint h1, uint l):
    h1 = h1 ^ l
    h1 ^= __rotr(h1, 16)
    h1 *= <uint>0x85ebca6b
    h1 ^= __rotr(h1, 13)
    h1 *= <uint>0xc2b2ae35
    return h1 ^ __rotr(h1, 16)

cdef uint m3_hash_int(int i):
    cdef uint k1
    cdef uint h1
    if i == 0:
        return i
    else:
        k1 = m3_mix_K1(i)
        h1 = m3_mix_H1(m3_seed, k1)
        return m3_fmix(h1, 4)

cdef uint m3_hash_unencoded_chars(unicode istr):
    cdef uint h1
    cdef uint i
    cdef uint alen = len(istr)

    h1 = m3_seed

    while i < alen:
        h1 = m3_mix_H1(h1, m3_mix_K1(ord(istr[i - 1]) | (ord(istr[i]) >> 16)))
        i = i + 2

    if alen & 1 == 1:
        h1 ^= m3_mix_K1(ord(istr[alen - 1]))

    return m3_fmix(h1, 2 * alen)

### String

_hash.extend(unicode, lambda x: m3_hash_unencoded_chars(x))

cdef dict _string_hash_cache
cdef uint _string_hash_cache_count

_string_hash_cache_count = 0
_string_hash_cache = {}

cdef uint hash_string(unicode s):
    cdef uint i
    cdef uint hash

    if s is None:
        return 0

    alen = len(s)
    i = 0
    hash = 0
    while i < alen:
        hash = (32 * hash) + ord(s[i])
        i += 1
    return hash


cdef uint add_to_string_hash_cache(unicode k):
    global _string_hash_cache_count
    if _string_hash_cache_count > 255:
        _string_hash_cache = {}
        _string_hash_cache_count = 0
    h = _string_hash_cache.get(k, -1)
    if h == -1:
        return add_to_string_hash_cache(k)
    return h

cdef uint mix_collection_hash(uint hash_basis, uint count):
    cdef uint h1
    cdef uint k1

    h1 = m3_seed
    k1 = m3_mix_K1(hash_basis)
    h1 = m3_mix_H1(h1, k1)
    return m3_fmix(h1, count)


cpdef uint hash_ordered_coll(coll):
    cdef uint n
    cdef uint hash_code

    n = <uint>0
    hash_code = <uint>1
    coll = seq(coll)
    while coll is not None:

        hash_code = (<uint>31 * hash_code) + <uint>hash(first(coll))
        n += <uint>1
        coll = next(coll)

    return  mix_collection_hash(hash_code, n)



### Hashing
import math

_hash.extend(float, lambda x: math.floor(x) % 2147483647)
_hash.extend(bool, int)
_hash.extend(unicode, lambda x: m3_hash_int(hash_string(x)))
_hash.extend(type(None), lambda x: 0)
_hash.extend(int, lambda x: m3_hash_int(<uint>x))

hash = _hash

### helpers

cpdef bint is_sequential(x):
    return ISequential.satisfied_by(type(x))

cpdef bint is_counted(x):
    return ICounted.satisfied_by(type(x))


cpdef bint equiv_sequential(x, y):
    if is_counted(x) and is_counted(y) and not count(x) == count(y):
        return False

    if is_sequential(y):
        xs = seq(x)
        ys = seq(y)

        while True:
            if xs is None:
                return ys is None
            if ys is None:
                return False
            if equiv(first(xs), first(ys)):
                xs = next(xs)
                ys = next(ys)
                continue
            return False
    else:
        return False

### Reducing Helpers

cdef class Reduced(object):
    cdef _val

    def __init__(self, val):
        self._val = val

@extend(_deref, Reduced)
def _deref(Reduced r):
    return r._val

def reduced(x):
    """Wraps x in a way such that a reduce will terminate with the value x"""
    return Reduced(x)

def is_reduced(x):
    return isinstance(x, Reduced)





cpdef array_reduce(arr, f, val = unset, uint i = 0):
    cdef uint cnt
    cnt = <uint>len(arr)

    if cnt == 0:
        return f()

    if val is unset:
        val = arr[0]
        n = <uint>1
    if i != 0:
        n = i

    while n < cnt:
        val = f(val, arr[n])
        if is_reduced(val):
            return deref(val)
        n += 1

    return val


### Symbol



cdef class Symbol(object):
    cdef unicode _ns
    cdef unicode _name
    cdef unicode _str
    cdef int _hash
    cdef _meta

    def __init__(self, _ns, _name, _str, _hash, _meta):
        self._ns = _ns
        self._name = _name
        self._str = _str
        self._hash = _hash
        self._meta = _meta

    def __str__(self):
        return self._str

    def __repr__(self):
        return self._str

    def __richcmp__(self, other, int cmp):
        if cmp == 2:
            return _equiv(self, other)
        elif cmp == 3:
            return not _equiv(self, other)
        else:
            raise ValueError("Can't compare Symbols")

    def __call__(self, coll, not_found = None):
        return _lookup(coll, self, not_found)

@extend(_equiv, Symbol)
def _equiv(Symbol self, other):
    if not isinstance(other, Symbol):
        return False
    cdef Symbol o = other
    return self._str == (<Symbol>o)._str

@extend(_meta, Symbol)
def _meta(Symbol self):
    return self._meta

@extend(_with_meta, Symbol)
def _with_meta(Symbol self, new_meta):
    return Symbol(self._ns, self._name, self._str, self._hash, new_meta)

@extend(_name, Symbol)
def _name(Symbol self):
    return self._name

@extend(_namespace, Symbol)
def _namespace(Symbol self):
    return self._ns

@extend(_hash, Symbol)
def _hash(Symbol self):
    if self._hash == 0:
        h = m3_hash_unencoded_chars(self._str)
        self._hash = h
        return h
    return self._hash


cpdef bint is_symbol(x):
    return isinstance(x, Symbol)


def symbol(*args):
    if len(args) == 1:
        name = args[0]
        if is_symbol(name):
            return name
        else:
            return symbol(None, name)
    elif len(args) == 2:
        ns = args[0]
        name = args[1]
        sym_str = ns + "/" + name if ns is not None else name
        return Symbol(ns, name, sym_str, 0, None)

meta = _meta
with_meta = _with_meta


cdef class IndexedSeq(object):
    cdef _arr
    cdef uint _i

    def __init__(self, arr, uint i):
        self._arr = arr
        self._i = i

    def __richcmp__(self, other, int c):
        if c == 2:
            return equiv(self, other)
        elif c == 3:
            return not equiv(self, other)
        else:
            raise ValueError("Can't compare Items")

    def __hash__(self):
        return hash(self)

@extend(_clone, IndexedSeq)
def _clone(IndexedSeq self):
    return IndexedSeq(self._arr, self._i)


ASeq.mark_satisfied(IndexedSeq)

@extend(_seq, IndexedSeq)
def _seq(IndexedSeq self):
    return self

@extend(_first, IndexedSeq)
def _first(IndexedSeq self):
    return self._arr[self._i]

@extend(_rest, IndexedSeq)
def _rest(IndexedSeq self):
    if self._i + 1 < len(self._arr):
        return IndexedSeq(self._arr, self._i + 1)
    return ()

@extend(_next, IndexedSeq)
def _next(IndexedSeq self):
    if self._i + 1 < len(self._arr):
        return IndexedSeq(self._arr, self._i + 1)
    return None

@extend(_count, IndexedSeq)
def _count(IndexedSeq self):
    return len(self._arr) - self._i

@extend(_nth, IndexedSeq)
def _nth(IndexedSeq self, n, not_found):
    i = n + self._i
    if i < len(self._arr):
        return self._arr[i]
    return not_found

ISequential.mark_satisfied(IndexedSeq)

_equiv.extend(IndexedSeq, equiv_sequential)


_hash.extend(IndexedSeq, hash_ordered_coll)


@extend(_reduce, IndexedSeq)
def _reduce(IndexedSeq self, f, start=unset):
    if start is not unset:
        return array_reduce(self._arr, f, self._arr[self._i], self._i + 1)
    else:
        return array_reduce(self._arr, f, start, self._i)

## Interop with other python types

_hash.extend(__builtins__.tuple, hash_ordered_coll)

@extend(_seq, __builtins__.list)
def _seq(coll):
    return IndexedSeq(coll, 0)


@extend(_seq, __builtins__.tuple)
def _seq(coll):
    return IndexedSeq(coll, 0)



### PersistentVector

cdef class VectorNode(object):
    cdef _edit
    cdef list _arr

    def __init__(self, _edit, list _arr):
        assert isinstance(_arr, list)
        self._edit = _edit
        self._arr = _arr

    def arr(self):
        return self._arr

cdef pv_fresh_node(edit):
    return VectorNode(edit, make_array(32))

cdef pv_aget(VectorNode node, uint idx):
    return node._arr[idx]

cdef VectorNode pv_aset(VectorNode node, uint idx, val):
    assert not isinstance(val, type)
    node._arr[idx] = val
    return node

cdef VectorNode pv_clone_node(VectorNode node):
    return VectorNode(node._edit, aclone(node._arr))

cdef class PersistentVector(object):
    cdef meta
    cdef uint cnt
    cdef uint shift
    cdef root
    cdef tail
    cdef __hash

    def __init__(self, meta, uint cnt, uint shift, VectorNode root, list tail, uint __hash = 0):
        self.meta = meta
        self.cnt = cnt
        self.shift = shift
        self.root = root
        self.tail = tail
        self.__hash = __hash

    def get_node(self):
        return self.root

    def get_tail(self):
        return self.tail


cdef uint tail_off(PersistentVector pv):
    cdef uint cnt
    cnt = pv.cnt
    if cnt < <uint>32:
        return 0
    return ((cnt - <uint>1) >> <uint>5) << <uint>5


cdef new_path(edit, uint level, VectorNode node):
    cdef uint ll
    ll = level
    ret = node

    while ll != 0:
        embed = ret
        r = pv_fresh_node(edit)
        ret = pv_aset(r, 0, embed)
        ll -= <uint>5

    return ret

cdef VectorNode push_tail(PersistentVector pv, uint level, VectorNode parent, VectorNode tailnode):
    cdef uint subidx
    cdef VectorNode ret
    ret = pv_clone_node(parent)
    subidx = ((pv.cnt - 1) >> level) & 0x01f

    if level == 5:
        pv_aset(ret, subidx, tailnode)
        return ret

    child = pv_aset(parent, subidx, tailnode)
    if child is not None:
        node_to_insert = push_tail(pv, level - 5, child, tailnode)
        pv_aset(ret, subidx, node_to_insert)
        return ret

    node_to_insert = new_path(None, level - 5, tailnode)
    pv_aset(ret, subidx, node_to_insert)
    return ret

cdef vector_index_out_of_bounds(i, cnt):
    raise Exception("No item " + str(i) + " in vector of length " + str(cnt))

cdef list first_array_for_longvec(PersistentVector pv):
    node = pv.root
    level = pv.shift
    while level > 0:
        node = pv_aget(node, 0)
        level -= 5

    return node._arr

cdef list unchecked_array_for(PersistentVector pv, uint i):
    cdef uint level
    cdef VectorNode node

    if i >= tail_off(pv):
        return pv.tail


    node = pv.root
    level = pv.shift
    while level > 0:
        node = pv_aget(node, (i >> level) & 0x01f)
        level -= 5
    return node._arr

cdef list array_for(PersistentVector pv, uint i):
    if 0 <= i < pv.cnt:
        return unchecked_array_for(pv, i)
    vector_index_out_of_bounds(i, pv.cnt)


cdef VectorNode EMPTY_VECTOR_NODE
EMPTY_VECTOR_NODE = VectorNode(None, make_array(32))

cdef PersistentVector EMPTY_VECTOR
EMPTY_VECTOR = PersistentVector(None, 0, 5, EMPTY_VECTOR_NODE, array())

@extend(_conj, PersistentVector)
def _conj(PersistentVector self, o):
    cdef uint alen
    cdef bint root_overflow
    cdef uint new_shift
    cdef VectorNode new_root

    if self.cnt - tail_off(self) < 32:
        alen = len(self.tail)
        new_tail = self.tail[:]
        new_tail.append(o)
        return PersistentVector(self.meta, self.cnt + 1, self.shift, self.root, new_tail)

    root_overflow = (self.cnt >> 5) > (1 << self.shift)
    new_shift = self.shift + 5 if root_overflow else self.shift

    if root_overflow:
        new_root = pv_fresh_node(None)
        pv_aset(new_root, 0, self.root)
        pv_aset(new_root, 1, new_path(None, self.shift, VectorNode(None, self.tail)))

    else:
        new_root = push_tail(self, self.shift, self.root, VectorNode(None, self.tail))

    return PersistentVector(self.meta, self.cnt + 1, new_shift, new_root, array(o))



@extend(_nth, PersistentVector)
def _nth(PersistentVector self, n, not_found):
    if 0 <= n <= self.cnt:
        v = unchecked_array_for(self, n)
        return v[n & 0x01f]
    return not_found


def vector():
    return EMPTY_VECTOR
