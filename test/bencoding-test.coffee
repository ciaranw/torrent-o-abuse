Bencoding = require('../src/bencoding')
assert = require('assert')

describe('Bencoding', () ->
    describe('Encoding', () ->
        it('should encode strings', () ->
            result = Bencoding.encode('hello')
            assert.deepEqual(result, new Buffer('5:hello'))
        )
        
        it('should encode buffers', () ->
            result = Bencoding.encode(new Buffer('hello'))
            assert.deepEqual(result, new Buffer('5:hello'))
        )
        
        it('should encode integers', () ->
            result = Bencoding.encode(1234)
            assert.deepEqual(result, new Buffer('i1234e'))
        )
        
        it('should encode arrays of strings', () ->
            result = Bencoding.encode(['hi', 'there'])
            assert.deepEqual(result, new Buffer('l2:hi5:theree'))
        )
        
        it('should encode arrays of integer', () ->
            result = Bencoding.encode([5,4,3,2])
            assert.deepEqual(result, new Buffer('li5ei4ei3ei2ee'))
        )
        
        it('should encode arrays of integers and strings', () ->
            result = Bencoding.encode([5,'str',2])
            assert.deepEqual(result, new Buffer('li5e3:stri2ee'))
        )
        
        it('should encode arrays that contain objects', () ->
            result = Bencoding.encode([
                text: 'value'
                num: 3141
            ])
            assert.deepEqual(result, new Buffer('ld4:text5:value3:numi3141eee'))
        )
        
        it('should encode objects that contain integers', () ->
            result = Bencoding.encode(test:5)
            assert.deepEqual(result, new Buffer('d4:testi5ee'))
        )
        
        it('should encode objects that contain strings', () ->
            result = Bencoding.encode(test: 'value')
            assert.deepEqual(result, new Buffer('d4:test5:valuee'))
        )
        
        it('should encode objects that contain strings and integers', () ->
            result = Bencoding.encode(
                test: 'value'
                num: 3141
            )
            assert.deepEqual(result, new Buffer('d4:test5:value3:numi3141ee'))
        )
        
        it('should encode objects that contain objects', () ->
            result = Bencoding.encode(
                test: 
                    text: 'value'
                    num: 3141
            )
            assert.deepEqual(result, new Buffer('d4:testd4:text5:value3:numi3141eee'))
        )
        
        it('should encode objects that contain arrays', () ->
            result = Bencoding.encode(
                test: ['value', 3141]
            )
            assert.deepEqual(result, new Buffer('d4:testl5:valuei3141eee'))
        )
    )
    
    describe('Decoding', () ->
        it('should decode strings', () ->
            result = Bencoding.decode(new Buffer('6:hello!'))
            assert.deepEqual(result, new Buffer('hello!'))
        )
        
        it('should decode long strings', () ->
            result = Bencoding.decode(new Buffer('12:Hi everyone!'))
            assert.deepEqual(result, new Buffer('Hi everyone!'))
        )
        
        it('should decode integers', () ->
            result = Bencoding.decode(new Buffer('i72e'))
            assert.equal(result, 72)
        )
        
        it('should decode arrays that contain integers', () ->
            result = Bencoding.decode(new Buffer('li5ei28ee'))
            assert.deepEqual(result, [5, 28])
        )
        
        it('should decode arrays that contain strings', () ->
            result = Bencoding.decode(new Buffer('l2:Hi5:Theree'))
            assert.deepEqual(result, [new Buffer('Hi'), new Buffer('There')])
        )
        
        it('should decode arrays that contain integers and strings', () ->
            result = Bencoding.decode(new Buffer('li72e5:Theree'))
            assert.deepEqual(result, [72, new Buffer('There')])
        )
        
        it('should decode objects that contain integers', () ->
            result = Bencoding.decode(new Buffer('d2:Hii88ee'))
            assert.deepEqual(result, Hi: 88)
        )
        
        it('should decode objects that contain strings', () ->
            result = Bencoding.decode(new Buffer('d2:Hi5:theree'))
            assert.deepEqual(result, Hi: new Buffer('there'))
        )
        
        it('should decode objects that contain integers and strings', () ->
            result = Bencoding.decode(new Buffer('d2:Hi5:there2:ohi88ee'))
            assert.deepEqual(result,
                Hi: new Buffer('there')
                oh: 88
            )
        )
        
        it('should decode objects that contain objects', () ->
            result = Bencoding.decode(new Buffer('d4:testd4:text5:value3:numi3141eee'))
            assert.deepEqual(result,
                test: 
                    text: new Buffer('value')
                    num: 3141
            )
        )
        
        it('should decode objects that contain arrays', () ->
            result = Bencoding.decode(new Buffer('d4:testl5:valuei3141eee'))
            assert.deepEqual(result, test: [new Buffer('value'), 3141])
        )
    )
)