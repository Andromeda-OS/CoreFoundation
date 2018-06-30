//
//  NSArray.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PureFoundation.h"
#import "FileLoaders.h"

// TODO: Don't need to implement these, but they could reduce an amount of duplication
// t __NSArrayRaiseBoundException
// t __NSArrayRaiseInsertNilException

#define ARRAY_CALLBACKS ((CFArrayCallBacks *)&_PFCollectionCallBacks)

// state is defined as "struct __objcFastEnumerationStateEquivalent" in CFArray.c
extern unsigned long _CFArrayFastEnumeration(CFArrayRef array, NSFastEnumerationState *state, void *stackbuffer, unsigned long count);

#pragma mark - utility functions

static CFArrayRef PFArrayInitFromVAList(void *first, va_list args) {
    va_list dargs;
    va_copy(dargs, args);
    
    CFIndex count = 1;
    while (va_arg(dargs, void *)) count++;
    va_end(dargs);
    
    void **values;
    if (count == 1) {
        values = &first;
    } else {
        void **ptr = values = malloc(count * sizeof(void *));
        *ptr++ = first;
        while ((*ptr++ = va_arg(args, void *))) {}
    }
    
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (const void **)values, count, ARRAY_CALLBACKS);
    if (count > 1) free(values);
    return array;
}

// Returns a pointer to an array of copied objects which the caller must free
static void ** PFArrayShallowCopy(CFArrayRef array, CFIndex count) {
    if (!count) count = CFArrayGetCount(array);
    void **values = calloc(count, sizeof(void *));
    CFArrayGetValues((CFArrayRef)array, CFRangeMake(0, count), (const void **)values);
    void **ptr = values;
    while (count--) {
        *ptr = [(id)*ptr copy];
        ptr++;
    }
    return values;
}

#pragma mark - callbacks

static void PFArrayFindObjectIndeticalTo(const void *value, void *context) {
    // context points to 3 NSUIntegers: result, position, and object address
    NSUInteger *ctx = (NSUInteger *)context;
    if (ctx[0] == NSNotFound) {
        if (ctx[2] == (NSUInteger)value) {
            ctx[0] = ctx[1];
        } else {
            ctx[1]++;
        }
    }
}

// The comparison function for sortUsingSelector:
static CFComparisonResult PFArraySortUsingSelector(const void *val1, const void *val2, void *context) {
    return (CFComparisonResult)[(id)val1 performSelector:(SEL)context withObject:(id)val2];
}

typedef struct _PerformSelectorContext {
    SEL selector;
    id object;
} _PerformSelectorContext;

static void PFArrayMakePerformSelector(const void *value, void *context) {
    [(id)value performSelector:((_PerformSelectorContext *)context)->selector withObject:((_PerformSelectorContext *)context)->object];
}


@implementation NSArray

#pragma mark - primatives

- (NSUInteger)count { return 0; }
- (id)objectAtIndex:(NSUInteger)index { return nil; }
- (id)firstObject { return nil; }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSCoding

// TODO: add secure coding

+ (BOOL)supportsSecureCoding { return YES; }
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }


#pragma mark - imutable factory methods

+ (instancetype)array {
    return [(id)CFArrayCreate(kCFAllocatorDefault, NULL, 0, ARRAY_CALLBACKS) autorelease];
}

+ (instancetype)arrayWithObject:(id)anObject {
    if (!anObject) {
        return [self array];
    }
    return [(id)CFArrayCreate(kCFAllocatorDefault, (const void **)&anObject, 1, ARRAY_CALLBACKS) autorelease];
}

+ (id)arrayWithObjects:(const id *)objects count:(NSUInteger)count {
    if (!objects || !count) {
        return [self array];
    }
    return [(id)CFArrayCreate(kCFAllocatorDefault, (const void **)objects, count, ARRAY_CALLBACKS) autorelease];
}

+ (id)arrayWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self array];
    }
    va_list args;
    va_start(args, firstObj);
    CFArrayRef array = PFArrayInitFromVAList(firstObj, args);
    va_end(args);
    return [(id)array autorelease];
}

+ (id)arrayWithArray:(NSArray *)array {
    return [(id)CFArrayCreateCopy(kCFAllocatorDefault, (CFArrayRef)array) autorelease];
}

// TODO:
// t +[NSArray arrayWithArray:copyItems:]
// t +[NSArray arrayWithArray:range:]
// t +[NSArray arrayWithArray:range:copyItems:]
// t +[NSArray arrayWithOrderedSet:]
// t +[NSArray arrayWithOrderedSet:copyItems:]
// t +[NSArray arrayWithOrderedSet:range:]
// t +[NSArray arrayWithOrderedSet:range:copyItems:]
// t +[NSArray arrayWithSet:]
// t +[NSArray arrayWithSet:copyItems:]
// t +[NSArray newArrayWithObjects:count:]

#pragma mark - immutable init methods

- (instancetype)init {
    free(self);
    return (id)CFArrayCreate(kCFAllocatorDefault, NULL, 0, ARRAY_CALLBACKS);
}

- (instancetype)initWithObjects:(const id *)objects count:(NSUInteger)count {
    free(self);
    if (!objects || !count) {
        return (id)CFArrayCreate(kCFAllocatorDefault, NULL, 0, ARRAY_CALLBACKS);
    }
    return (id)CFArrayCreate(kCFAllocatorDefault, (const void **)objects, count, ARRAY_CALLBACKS);
}

- (id)initWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObj);
    CFArrayRef array = PFArrayInitFromVAList(firstObj, args);
    va_end(args);
    return (id)array;
}

- (instancetype)initWithArray:(NSArray *)array {
    free(self);
    return (id)CFArrayCreateCopy(kCFAllocatorDefault, (CFArrayRef)array);
}

// TODO: Check what macOS Foundation returns when pass a nil array
- (id)initWithArray:(NSArray *)array copyItems:(BOOL)copy {
    if (!array) {
        return [self init];
    }
    free (self);
    CFIndex count = CFArrayGetCount((CFArrayRef)array);
    if (!copy || !count) {
        return (id)CFArrayCreateCopy(kCFAllocatorDefault, (CFArrayRef)array);
    }
    
    void **values = PFArrayShallowCopy((CFArrayRef)array, count);
    CFArrayRef newArray = CFArrayCreate(kCFAllocatorDefault, (const void **)values, count, ARRAY_CALLBACKS);
    free(values);
    return (id)newArray;
}


// TODO:
// t -[NSArray initWithArray:range:]
// t -[NSArray initWithArray:range:copyItems:]
// t -[NSArray initWithCoder:]
// t -[NSArray initWithObject:]
// t -[NSArray initWithOrderedSet:]
// t -[NSArray initWithOrderedSet:copyItems:]
// t -[NSArray initWithOrderedSet:range:]
// t -[NSArray initWithOrderedSet:range:copyItems:]
// t -[NSArray initWithSet:]
// t -[NSArray initWithSet:copyItems:]

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len { return 0; }

#pragma mark - Implementations using atomic methods

// TODO
// t -[NSArray _cfTypeID]
// t -[NSArray _initByAdoptingBuffer:count:size:]
// t -[NSArray allObjects]
// t -[NSArray arrayByAddingObject:]
// t -[NSArray arrayByAddingObjectsFromArray:]
// t -[NSArray arrayByApplyingSelector:]
// t -[NSArray arrayByExcludingObjectsInArray:]
// t -[NSArray arrayByExcludingToObjectsInArray:]
// t -[NSArray componentsJoinedByString:]
// t -[NSArray containsObject:]
// t -[NSArray containsObject:inRange:]
// t -[NSArray containsObjectIdenticalTo:]
// t -[NSArray containsObjectIdenticalTo:inRange:]
// t -[NSArray copyWithZone:]
// t -[NSArray countByEnumeratingWithState:objects:count:]
// t -[NSArray countForObject:]
// t -[NSArray countForObject:inRange:]
// t -[NSArray count]
// t -[NSArray descriptionWithLocale:]
// t -[NSArray descriptionWithLocale:indent:]
// t -[NSArray description]
// t -[NSArray encodeWithCoder:]
// t -[NSArray enumerateObjectsAtIndexes:options:usingBlock:]
// t -[NSArray enumerateObjectsUsingBlock:]
// t -[NSArray enumerateObjectsWithOptions:usingBlock:]
// t -[NSArray firstObjectCommonWithArray:]
// t -[NSArray firstObject]
// t -[NSArray getObjects:]
// t -[NSArray getObjects:range:]
// t -[NSArray hash]
// t -[NSArray indexOfObject:]
// t -[NSArray indexOfObject:inRange:]
// t -[NSArray indexOfObject:inSortedRange:options:usingComparator:]
// t -[NSArray indexOfObjectAtIndexes:options:passingTest:]
// t -[NSArray indexOfObjectIdenticalTo:]
// t -[NSArray indexOfObjectIdenticalTo:inRange:]
// t -[NSArray indexOfObjectPassingTest:]
// t -[NSArray indexOfObjectWithOptions:passingTest:]
// t -[NSArray indexesOfObject:]
// t -[NSArray indexesOfObject:inRange:]
// t -[NSArray indexesOfObjectIdenticalTo:]
// t -[NSArray indexesOfObjectIdenticalTo:inRange:]
// t -[NSArray indexesOfObjectsAtIndexes:options:passingTest:]
// t -[NSArray indexesOfObjectsPassingTest:]
// t -[NSArray indexesOfObjectsWithOptions:passingTest:]
// t -[NSArray isEqual:]
// t -[NSArray isEqualToArray:]
// t -[NSArray isNSArray__]
// t -[NSArray lastObject]
// t -[NSArray makeObjectsPerformSelector:]
// t -[NSArray makeObjectsPerformSelector:withObject:]
// t -[NSArray mutableCopyWithZone:]
// t -[NSArray objectAtIndex:]
// t -[NSArray objectAtIndexedSubscript:]
// t -[NSArray objectAtIndexes:options:passingTest:]
// t -[NSArray objectEnumerator]
// t -[NSArray objectPassingTest:]
// t -[NSArray objectWithOptions:passingTest:]
// t -[NSArray objectsAtIndexes:]
// t -[NSArray objectsAtIndexes:options:passingTest:]
// t -[NSArray objectsPassingTest:]
// t -[NSArray objectsWithOptions:passingTest:]
// t -[NSArray reverseObjectEnumerator]
// t -[NSArray reversedArray]
// t -[NSArray sortedArrayFromRange:options:usingComparator:]
// t -[NSArray sortedArrayUsingComparator:]
// t -[NSArray sortedArrayUsingFunction:context:]
// t -[NSArray sortedArrayUsingSelector:]
// t -[NSArray sortedArrayWithOptions:usingComparator:]
// t -[NSArray subarrayWithRange:]

@end

@implementation NSMutableArray

#pragma mark - Factory methods

+ (instancetype)arrayWithCapacity:(NSUInteger)capacity {
    return [(id)CFArrayCreateMutable(kCFAllocatorDefault, capacity, ARRAY_CALLBACKS) autorelease];
}

+ (instancetype)array {
    return [(id)CFArrayCreateMutable(kCFAllocatorDefault, 0, ARRAY_CALLBACKS) autorelease];
}

+ (instancetype)arrayWithObject:(id)anObject {
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, ARRAY_CALLBACKS);
    if (anObject) {
        CFArrayAppendValue(array, anObject);
    }
    return [(id)array autorelease];
}

+ (id)arrayWithObjects:(const id *)objects count:(NSUInteger)count {
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (const void **)objects, count, ARRAY_CALLBACKS);
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, array);
    CFRelease(array);
    return [(id)mArray autorelease];
}

+ (id)arrayWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self array];
    }
    va_list args;
    va_start(args, firstObj);
    CFArrayRef array = PFArrayInitFromVAList(firstObj, args);
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, array);
    CFRelease(array);
    va_end(args);
    return [(id)mArray autorelease];
}

+ (instancetype)arrayWithArray:(NSArray *)array {
    return [(id)CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, (CFArrayRef)array) autorelease];
}

// TODO:
// t +[NSArray arrayWithArray:copyItems:]
// t +[NSArray arrayWithArray:range:]
// t +[NSArray arrayWithArray:range:copyItems:]
// t +[NSArray arrayWithOrderedSet:]
// t +[NSArray arrayWithOrderedSet:copyItems:]
// t +[NSArray arrayWithOrderedSet:range:]
// t +[NSArray arrayWithOrderedSet:range:copyItems:]
// t +[NSArray arrayWithSet:]
// t +[NSArray arrayWithSet:copyItems:]
// t +[NSArray newArrayWithObjects:count:]

#pragma mark - Mutable init methods

- (instancetype)init {
    free(self);
    return (id)CFArrayCreateMutable(kCFAllocatorDefault, 0, ARRAY_CALLBACKS);
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    free(self);
    return (id)CFArrayCreateMutable(kCFAllocatorDefault, capacity, ARRAY_CALLBACKS);
}

- (instancetype)initWithObjects:(const id *)objects count:(NSUInteger)count {
    free(self);
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (const void **)objects, (CFIndex)count, ARRAY_CALLBACKS);
    CFArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, count, array);
    CFRelease(array);
    return (id)mArray;
}

- (id)initWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObj);
    CFArrayRef array = PFArrayInitFromVAList(firstObj, args);
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, array);
    CFRelease(array);
    va_end(args);
    return (id)mArray;
}

- (instancetype)initWithArray:(NSArray *)array {
    free(self);
    return (id)CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, (CFArrayRef)array);
}

// TODO: Write some benchmarks to test whether it is quicker to create a mutable array and copy+append each item in turn
- (instancetype)initWithArray:(NSArray *)array copyItems:(BOOL)copy {
    if (!array) {
        return [self init]; // TODO: Check whether this is the correct behaviour
    }
    free (self);
    CFIndex count = CFArrayGetCount((CFArrayRef)array);
    if (!copy || !count) {
        return (id)CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, (CFArrayRef)array);
    }
    void **values = PFArrayShallowCopy((CFArrayRef)array, count);
    CFArrayRef newArray = CFArrayCreate(kCFAllocatorDefault, (const void **)values, count, ARRAY_CALLBACKS);
    free(values);
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, newArray);
    CFRelease(newArray);
    return (id)mArray;
}

// TODO:
// t -[NSArray initWithArray:range:]
// t -[NSArray initWithArray:range:copyItems:]
// t -[NSArray initWithCoder:]
// t -[NSArray initWithObject:]
// t -[NSArray initWithOrderedSet:]
// t -[NSArray initWithOrderedSet:copyItems:]
// t -[NSArray initWithOrderedSet:range:]
// t -[NSArray initWithOrderedSet:range:copyItems:]
// t -[NSArray initWithSet:]
// t -[NSArray initWithSet:copyItems:]

- (id)initWithCoder:(NSCoder *)aDecoder {
    // PF_TODO
    free(self);
    return nil;
}

// Instance method prototypes
- (void)addObject:(id)anObject {}
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {}
- (void)removeLastObject {}
- (void)removeObjectAtIndex:(NSUInteger)index {}
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {}

// TODO:
// t -[NSMutableArray _mutate]
// t -[NSMutableArray addObject:]
// t -[NSMutableArray addObjects:count:]
// t -[NSMutableArray addObjectsFromArray:]
// t -[NSMutableArray addObjectsFromArray:range:]
// t -[NSMutableArray addObjectsFromOrderedSet:]
// t -[NSMutableArray addObjectsFromOrderedSet:range:]
// t -[NSMutableArray addObjectsFromSet:]
// t -[NSMutableArray exchangeObjectAtIndex:withObjectAtIndex:]
// t -[NSMutableArray insertObject:atIndex:]
// t -[NSMutableArray insertObjects:atIndexes:]
// t -[NSMutableArray insertObjects:count:atIndex:]
// t -[NSMutableArray insertObjectsFromArray:atIndex:]
// t -[NSMutableArray insertObjectsFromArray:range:atIndex:]
// t -[NSMutableArray insertObjectsFromOrderedSet:atIndex:]
// t -[NSMutableArray insertObjectsFromOrderedSet:range:atIndex:]
// t -[NSMutableArray insertObjectsFromSet:atIndex:]
// t -[NSMutableArray moveObjectsAtIndexes:toIndex:]
// t -[NSMutableArray removeAllObjects]
// t -[NSMutableArray removeFirstObject]
// t -[NSMutableArray removeLastObject]
// t -[NSMutableArray removeObject:]
// t -[NSMutableArray removeObject:inRange:]
// t -[NSMutableArray removeObjectAtIndex:]
// t -[NSMutableArray removeObjectIdenticalTo:]
// t -[NSMutableArray removeObjectIdenticalTo:inRange:]
// t -[NSMutableArray removeObjectsAtIndexes:]
// t -[NSMutableArray removeObjectsAtIndexes:options:passingTest:]
// t -[NSMutableArray removeObjectsInArray:]
// t -[NSMutableArray removeObjectsInArray:range:]
// t -[NSMutableArray removeObjectsInOrderedSet:]
// t -[NSMutableArray removeObjectsInOrderedSet:range:]
// t -[NSMutableArray removeObjectsInRange:]
// t -[NSMutableArray removeObjectsInRange:inArray:]
// t -[NSMutableArray removeObjectsInRange:inArray:range:]
// t -[NSMutableArray removeObjectsInRange:inOrderedSet:]
// t -[NSMutableArray removeObjectsInRange:inOrderedSet:range:]
// t -[NSMutableArray removeObjectsInRange:inSet:]
// t -[NSMutableArray removeObjectsInSet:]
// t -[NSMutableArray removeObjectsPassingTest:]
// t -[NSMutableArray removeObjectsWithOptions:passingTest:]
// t -[NSMutableArray replaceObject:]
// t -[NSMutableArray replaceObject:inRange:]
// t -[NSMutableArray replaceObjectAtIndex:withObject:]
// t -[NSMutableArray replaceObjectsAtIndexes:withObjects:]
// t -[NSMutableArray replaceObjectsInRange:withObjects:count:]
// t -[NSMutableArray replaceObjectsInRange:withObjectsFromArray:]
// t -[NSMutableArray replaceObjectsInRange:withObjectsFromArray:range:]
// t -[NSMutableArray replaceObjectsInRange:withObjectsFromOrderedSet:]
// t -[NSMutableArray replaceObjectsInRange:withObjectsFromOrderedSet:range:]
// t -[NSMutableArray replaceObjectsInRange:withObjectsFromSet:]
// t -[NSMutableArray setArray:]
// t -[NSMutableArray setObject:atIndex:]
// t -[NSMutableArray setObject:atIndexedSubscript:]
// t -[NSMutableArray setOrderedSet:]
// t -[NSMutableArray setSet:]
// t -[NSMutableArray sortRange:options:usingComparator:]
// t -[NSMutableArray sortUsingComparator:]
// t -[NSMutableArray sortUsingFunction:context:]
// t -[NSMutableArray sortUsingFunction:context:range:]
// t -[NSMutableArray sortUsingSelector:]
// t -[NSMutableArray sortWithOptions:usingComparator:]
// t -[NSMutableArray sortedArrayFromRange:options:usingComparator:]

@end

#define SELF ((CFArrayRef)self)
#define MSELF ((CFMutableArrayRef)self)

@interface __NSCFArray : NSMutableArray
@end

@implementation __NSCFArray

#pragma mark - CF bridging

// TODO:
// t +[__NSCFArray automaticallyNotifiesObserversForKey:]
// t -[__NSCFArray _isDeallocating]
// t -[__NSCFArray _tryRetain]
// t -[__NSCFArray classForCoder]

-(CFTypeID)_cfTypeID {
    return CFArrayGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

/*
 *    sjc -- 9/2/09 -- The format now matches Cocoa's. I thought.
 *
 *    Four spaces are placed before each array element. If a tab is chosen, that is placed
 *    before the four spaces.
 *
 *    At the moment, this won't pass on [descriptionWithLocale:indent:] because I'm not sure
 *    how other objects should react adding the indent...
 */
- (NSString *)description {
    return [self descriptionWithLocale:nil indent:0];
}

- (NSString *)descriptionWithLocale:(id)locale {
    return [self descriptionWithLocale:locale indent:0];
}

// TODO: check that this works and looks sane
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSUInteger count = CFArrayGetCount((CFArrayRef)self);
    CFStringRef description, template, contents;
    id object;
    
    if( count == 0 )
        return (level == 1) ?  @"\t(\n\t)" : @"(\n)";
    
    template = (level == 1) ? CFSTR("\t(\n\t    %@\n\t)") : CFSTR("(\n    %@\n)");
    
    if( count == 1 )
    {
        object = (id)CFArrayGetValueAtIndex( (CFArrayRef)self, 0 );
        if( [object isKindOfClass: [NSString class]] )
            contents = (CFStringRef)object;
        else if( (locale != nil) && [object respondsToSelector: @selector(descriptionWithLocale:)] )
            contents = (CFStringRef)[object descriptionWithLocale: locale];
        else
            contents = (CFStringRef)[object description];
    }
    else
    {
        id *buffer = calloc(count, sizeof(id));
        for( object in self )
        {
            if( [object isKindOfClass: [NSString class]] ) // strings are included as is
                *buffer++ = object;
            else if( (locale != nil) && [object respondsToSelector: @selector(descriptionWithLocale:)] )
                *buffer++ = [object descriptionWithLocale: locale];
            else
                *buffer++ = [object description];
        }
        buffer -= count;
        
        CFStringRef joiner = (level == 1) ? CFSTR(",\n\t    ") : CFSTR(",\n    ");
        CFArrayRef array = CFArrayCreate( kCFAllocatorDefault, (const void **)buffer, count, NULL );
        contents = CFStringCreateByCombiningStrings( kCFAllocatorDefault, array, joiner );
        
        free(buffer);
        [(id)array release];
        [(id)contents autorelease];
    }
    
    return [(id)CFStringCreateWithFormat(kCFAllocatorDefault, NULL, template, contents) autorelease];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return (id)CFArrayCreateCopy(kCFAllocatorDefault, SELF);
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return (id)CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    return _CFArrayFastEnumeration(SELF, state, stackbuf, len);
}

#pragma mark - saving arrays

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically {
    if (!path.length) return NO;
    return PFPropertyListWriteToPath(SELF, (CFStringRef)path, atomically, NULL);
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically {
    if (!url) return NO;
    return PFPropertyListWriteToURL(SELF, (CFURLRef)url, atomically, NULL);
}

#pragma mark - primatives

- (NSUInteger)count {
    return (NSUInteger)CFArrayGetCount(SELF);
}

- (id)objectAtIndex:(NSUInteger)index {
    return (id)CFArrayGetValueAtIndex(SELF, (CFIndex)index);
}

#pragma mark - NSArray (NSExtendedArray)

- (NSArray *)arrayByAddingObject:(id)anObject {
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    if (anObject) {
        CFArrayAppendValue(mArray, &anObject);
    }
    return [(id)mArray autorelease];
}

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)otherArray {
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFIndex count = 0;
    if (otherArray && (count = CFArrayGetCount((CFArrayRef)otherArray))) {
        CFArrayAppendArray(mArray, (CFArrayRef)otherArray, CFRangeMake(0, count));
    }
    return [(id)mArray autorelease];
}

- (NSString *)componentsJoinedByString:(NSString *)separator {
    return [(id)CFStringCreateByCombiningStrings(kCFAllocatorDefault, SELF, (CFStringRef)separator) autorelease];
}

- (BOOL)containsObject:(id)anObject {
    CFIndex count = CFArrayGetCount(SELF);
    if (!anObject || !count) return NO;
    return CFArrayContainsValue(SELF, CFRangeMake(0, count), (const void *)anObject);
}

- (id)firstObjectCommonWithArray:(NSArray *)otherArray {
    if (otherArray && CFArrayGetCount(SELF) && [otherArray count]) {
        for (id object in self) {
            if ([otherArray containsObject:object]) return object;
        }
    }
    return nil;
}

- (void)getObjects:(id *)objects {
    CFIndex count = CFArrayGetCount(SELF);
    if (!objects || !count) return;
    CFArrayGetValues(SELF, CFRangeMake(0, count), (const void **)objects);
}

- (void)getObjects:(id *)objects range:(NSRange)range {
    NSUInteger count = CFArrayGetCount(SELF);
    if (!objects || !count) return;
    
    if (range.location >= count || range.location + range.length > count) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    
    CFArrayGetValues(SELF, CFRangeMake(range.location, range.length), (const void **)objects);
}

- (NSUInteger)indexOfObject:(id)anObject {
    CFIndex count = CFArrayGetCount(SELF);
    if (!anObject || !count) return NSNotFound;
    CFIndex index = CFArrayGetFirstIndexOfValue(SELF, CFRangeMake(0, count), (const void *)anObject);
    return index == -1 ? NSNotFound : index;
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range {
    NSUInteger count = CFArrayGetCount(SELF);
    if (!anObject || !count) return NSNotFound;
    
    if (range.location >= count || range.location + range.length > count) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    
    CFIndex result = CFArrayGetFirstIndexOfValue(SELF, CFRangeMake(range.location, range.length), (const void *)anObject);
    return result == -1 ? NSNotFound : result;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject {
    CFIndex count = CFArrayGetCount(SELF);
    if (!anObject || !count) return NSNotFound;
    NSUInteger context[3] = { NSNotFound, 0, (NSUInteger)anObject };
    CFArrayApplyFunction(SELF, CFRangeMake(0, count), PFArrayFindObjectIndeticalTo, context);
    return context[0];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    NSUInteger count = CFArrayGetCount(SELF);
    if (!anObject || !count) return NSNotFound;
    
    if (range.location >= count || range.location + range.length > count) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    
    NSUInteger context[3] = { NSNotFound, range.location, (NSUInteger)anObject };
    CFArrayApplyFunction(SELF, CFRangeMake(range.location, range.length), PFArrayFindObjectIndeticalTo, context);
    return context[0];
}

- (BOOL)isEqualToArray:(NSArray *)otherArray {
    if (!otherArray) return NO;
    return (self == otherArray) || CFEqual((CFTypeRef)self, (CFTypeRef)otherArray);
}

- (id)firstObject {
    CFIndex count = CFArrayGetCount(SELF);
    return count ? (id)CFArrayGetValueAtIndex(SELF, 0) : nil;
}

- (id)lastObject {
    CFIndex count = CFArrayGetCount(SELF);
    return count ? (id)CFArrayGetValueAtIndex(SELF, --count) : nil;
}

// These skip NSEnumerator and instantiate our own enumerator subclass
- (NSEnumerator *)objectEnumerator {
//    return [[[PFEnumerator alloc] initWithCFArray:self] autorelease];
    // TODO: Implement NSEnumerator
    return nil;
}

- (NSEnumerator *)reverseObjectEnumerator {
//    return [[[PFReverseEnumerator alloc] initWithCFArray:self] autorelease];
    // TODO: Implement NSEnumerator
    return nil;
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context {
    NSUInteger count = CFArrayGetCount(SELF);
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    if (comparator && count > 0) {
        CFArraySortValues(mArray, CFRangeMake(0, count), (CFComparatorFunction)comparator, context);
    }
    return [(id)mArray autorelease];
}

/*    "Analyzes the receiver and returns a “hint” that speeds the sorting of the array when the
 *    hint is supplied to sortedArrayUsingFunction:context:hint:."
 */
- (NSData *)sortedArrayHint {
    // PF_TODO
    return nil;
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint {
    // PF_TODO
    return [self sortedArrayUsingFunction:comparator context:context];
}

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator {
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFIndex count = CFArrayGetCount(SELF);
    if (comparator && count > 1) {
        CFArraySortValues(mArray, CFRangeMake(0, count), PFArraySortUsingSelector, (void *)comparator);
    }
    return [(id)mArray autorelease];
}

// TODO: This is added in NSSortDescriptor.h, and will be implemented once sort decriptors are
- (NSArray *)sortedArrayUsingDescriptors:(NSArray *)sortDescriptors { return nil; }

- (NSArray *)subarrayWithRange:(NSRange)range {
    NSUInteger count = CFArrayGetCount(SELF);
    if (!count || !range.length) {
        return [(id)CFArrayCreate(kCFAllocatorDefault, NULL, 0, ARRAY_CALLBACKS) autorelease];
    }
    if (range.location >= count || range.location + range.length > count) {
        [NSException raise: NSRangeException format:@"TODO"];
    }
    
    void **values = calloc(range.length, sizeof(void *));
    CFArrayGetValues(SELF, CFRangeMake(range.location, range.length), (const void **)values);
    CFArrayRef newArray = CFArrayCreate(kCFAllocatorDefault, (const void **)values, range.length, ARRAY_CALLBACKS);
    free(values);
    return [(id)newArray autorelease];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector {
    CFIndex count = CFArrayGetCount(SELF);
    if (!aSelector || !count) return;
    _PerformSelectorContext context = { aSelector, nil };
    CFArrayApplyFunction(SELF, CFRangeMake(0, count), PFArrayMakePerformSelector, &context);
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
    CFIndex count = CFArrayGetCount(SELF);
    if (!aSelector || !count) return;
    _PerformSelectorContext context = { aSelector, argument };
    CFArrayApplyFunction(SELF, CFRangeMake(0, count), PFArrayMakePerformSelector, &context);
}

// TODO: Requires NSIndexSet
- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
    // PF_TODO
    return nil;
}

// NSMutableArray specific instance methods

- (void)addObject:(id)anObject {
    if (!anObject) return;
    CFArrayAppendValue(MSELF, (const void *)anObject);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    if (index > CFArrayGetCount(SELF)) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    CFArrayInsertValueAtIndex(MSELF, index, (const void *)anObject);
}

- (void)removeLastObject {
    CFIndex count = CFArrayGetCount(SELF);
    if (!count) return;
    CFArrayRemoveValueAtIndex(MSELF, --count);
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    if (index >= CFArrayGetCount(SELF)) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    CFArrayRemoveValueAtIndex(MSELF, index);
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (!anObject) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    if (index >= CFArrayGetCount(SELF)) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    CFArraySetValueAtIndex(MSELF, index, (const void *)anObject);
}

// NSMutableArray (NSExtendedMutableArray)

- (void)addObjectsFromArray:(NSArray *)otherArray {
    CFIndex count = 0;
    if (otherArray && (count = CFArrayGetCount((CFArrayRef)otherArray))) {
        CFArrayAppendArray(MSELF, (CFArrayRef)otherArray, CFRangeMake(0, count));
    }
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    CFIndex count = CFArrayGetCount(SELF);
    if (idx1 >= count || idx2 >= count) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    CFArrayExchangeValuesAtIndices(MSELF, idx1, idx2);
}

- (void)removeAllObjects {
    CFArrayRemoveAllValues(MSELF);
}

- (void)removeObject:(id)anObject inRange:(NSRange)range {
    CFIndex count = CFArrayGetCount(SELF);
    if (range.location >= count || range.location + range.length > count) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    CFIndex index = CFArrayGetFirstIndexOfValue(SELF, CFRangeMake(range.location, range.length), (const void *)anObject);
    if (index != -1) {
        CFArrayRemoveValueAtIndex(MSELF, index);
    }
}

- (void)removeObject:(id)anObject {
    CFIndex count = CFArrayGetCount(SELF);
    if (!count) return;
    CFRange range = CFRangeMake(0, count);
    CFIndex index;
    do {
        index = CFArrayGetFirstIndexOfValue(SELF, range, (const void *)anObject);
        if (index != -1) {
            CFArrayRemoveValueAtIndex(MSELF, index);
            range.location = index;
            range.length = count - index;
        }
    } while (index != -1 && range.length);
}

- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    NSUInteger index = NSNotFound;
    NSUInteger end = range.location + range.length;
    do {
        index = [self indexOfObjectIdenticalTo:anObject inRange:range];
        if (index != NSNotFound) {
            CFArrayRemoveValueAtIndex(MSELF, index);
            range.location = index;
            range.length = end - index;
        }
    } while (index != NSNotFound && range.length);
}

- (void)removeObjectIdenticalTo:(id)anObject {
    NSUInteger index = NSNotFound;
    NSUInteger count = CFArrayGetCount(SELF);
    NSRange range = NSMakeRange(0, count);
    do {
        index = [self indexOfObjectIdenticalTo: anObject];
        if (index != NSNotFound) {
            CFArrayRemoveValueAtIndex(MSELF, index);
            range.location = index;
            range.length = count - index;
        }
    } while (index != NSNotFound && range.length);
}

- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)indexCount {
    CFIndex count = CFArrayGetCount(SELF);
    if (!count || !indices || !indexCount) return;
    while (indexCount--) {
        NSUInteger index = *indices++;
        if (index >= count) {
            [NSException raise:NSRangeException format:@"TODO"];
        }
        CFArrayRemoveValueAtIndex(MSELF, index);
        count--;
    }
}

- (void)removeObjectsInArray:(NSArray *)otherArray {
    if (!CFArrayGetCount(SELF) || ![otherArray count]) return;
    for (id object in otherArray) {
        [self removeObject:object];
    }
}

// Unlike the implementation described in Apple's documentation, this version does not use -removeObjectAtIndex:
- (void)removeObjectsInRange:(NSRange)range {
    CFIndex count = CFArrayGetCount(SELF);
    if (range.location >= count || range.location + range.length > count) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    CFArrayReplaceValues(MSELF, CFRangeMake(range.location, range.length), NULL, 0);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange {
    CFIndex count = CFArrayGetCount(SELF);
    if (range.location >= count || range.location + range.length > count) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    
    NSUInteger otherCount = [otherArray count];
    if (otherRange.location > otherCount || otherRange.location + otherRange.length > otherCount) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    
    void **values = calloc(otherRange.length, sizeof(void *));
    [otherArray getObjects:(id *)values range:otherRange];
    CFArrayReplaceValues(MSELF, CFRangeMake(range.location, range.length), (const void **)values, otherRange.length);
    free(values);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray {
    [self replaceObjectsInRange:range withObjectsFromArray:otherArray range:NSMakeRange(0, [otherArray count])];
}

- (void)setArray:(NSArray *)otherArray {
    CFArrayRemoveAllValues(MSELF);
    NSUInteger otherCount = [otherArray count];
    if (otherCount) {
        void **values = calloc(otherCount, sizeof(void *));
        [otherArray getObjects:(id *)values];
        CFArrayReplaceValues(MSELF, CFRangeMake(0, 0), (const void **)values, otherCount);
        free(values);
    }
}

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context {
    CFIndex count = CFArrayGetCount(SELF);
    if (!compare || count < 2) return;
    CFArraySortValues(MSELF, CFRangeMake(0, count), (CFComparatorFunction)compare, context);
}

- (void)sortUsingSelector:(SEL)comparator {
    CFIndex count = CFArrayGetCount(SELF);
    if (!comparator || count < 2) return;
    CFArraySortValues(MSELF, CFRangeMake(0, count), PFArraySortUsingSelector, (void *)comparator);
}

// TODO: These methods require NSIndexSet

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    // PF_TODO
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    // PF_TODO
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    // PF_TODO
}

@end

#undef ARRAY_CALLBACKS
#undef SELF
#undef MSELF

// NSCFArray exists in macOS CoreFoundation, but its purpose is unclear
//00000000005d7ac8 s _OBJC_CLASS_$_NSCFArray
//00000000005d7aa0 s _OBJC_METACLASS_$_NSCFArray

/*
    The following are mostly implementation details, so we shouldn't need to replicate them exactly

blocks:
0000000000189720 t ___27-[NSArray indexesOfObject:]_block_invoke
0000000000127e30 t ___27-[__NSArrayM copyWithZone:]_block_invoke
000000000011fdc0 t ___28+[__NSArray0 allocWithZone:]_block_invoke
0000000000189b40 t ___28-[NSArray objectsAtIndexes:]_block_invoke
0000000000127f40 t ___34-[__NSArrayM mutableCopyWithZone:]_block_invoke
0000000000189620 t ___35-[NSArray indexesOfObject:inRange:]_block_invoke
00000000000a5720 t ___36-[NSArray sortedArrayUsingSelector:]_block_invoke
00000000001899b0 t ___38-[NSArray indexesOfObjectIdenticalTo:]_block_invoke
00000000000a52a0 t ___44-[NSArray sortedArrayUsingFunction:context:]_block_invoke
00000000001898d0 t ___46-[NSArray indexesOfObjectIdenticalTo:inRange:]_block_invoke
0000000000089b80 t ___53-[__NSArrayI enumerateObjectsWithOptions:usingBlock:]_block_invoke
00000000000a5280 t ___56-[NSArray sortedArrayFromRange:options:usingComparator:]_block_invoke
00000000001b70d0 t ___62-[__NSArrayI_Transfer enumerateObjectsWithOptions:usingBlock:]_block_invoke

0000000000158650 t _____NSArrayEnumerate_block_invoke
00000000001587a0 t _____NSArrayGetIndexPassingTest_block_invoke
00000000001588f0 t _____NSArrayGetIndexesPassingTest_block_invoke

00000000000a85b0 t ___36-[NSMutableArray sortUsingSelector:]_block_invoke
00000000000a2d90 t ___44-[NSMutableArray sortUsingFunction:context:]_block_invoke
000000000019d1a0 t ___50-[NSMutableArray sortUsingFunction:context:range:]_block_invoke
00000000000a2d70 t ___52-[NSMutableArray sortRange:options:usingComparator:]_block_invoke

 00000000005d6d08 s _OBJC_METACLASS_$___NSArray0
 00000000005d8568 s _OBJC_METACLASS_$___NSArrayI
 00000000005d85b8 s _OBJC_METACLASS_$___NSArrayI_Transfer
 00000000005d6e70 s _OBJC_METACLASS_$___NSArrayM
 00000000005d81f8 s _OBJC_METACLASS_$___NSArrayReverseEnumerator
 00000000005d81a8 s _OBJC_METACLASS_$___NSArrayReversed


00000000005ddbe0 D ___NSArray0__
0000000000118970 t ___NSArrayChunkIterate
00000000000a0870 t ___NSArrayEnumerate
00000000000a5880 t ___NSArrayGetIndexPassingTest
00000000000ab680 t ___NSArrayGetIndexesPassingTest
00000000000a0720 t ___NSArrayParameterCheckIterate
00000000005ddbf8 d ___NSArray_cowCallbacks


misc:
00000000005d6ce0 s _OBJC_CLASS_$___NSArray0
00000000005d8540 s _OBJC_CLASS_$___NSArrayI
00000000005d8590 s _OBJC_CLASS_$___NSArrayI_Transfer
00000000005d6e20 s _OBJC_CLASS_$___NSArrayM
00000000005d81d0 s _OBJC_CLASS_$___NSArrayReverseEnumerator
00000000005d8180 s _OBJC_CLASS_$___NSArrayReversed

00000000005d67d0 s _OBJC_IVAR_$___NSArrayI._list
00000000005d67c8 s _OBJC_IVAR_$___NSArrayI._used
00000000005d67e0 s _OBJC_IVAR_$___NSArrayI_Transfer._list
00000000005d67d8 s _OBJC_IVAR_$___NSArrayI_Transfer._used
00000000005d6180 s _OBJC_IVAR_$___NSArrayM.cow
00000000005d6178 s _OBJC_IVAR_$___NSArrayM.storage
00000000005d66f8 s _OBJC_IVAR_$___NSArrayReverseEnumerator._idx
00000000005d66f0 s _OBJC_IVAR_$___NSArrayReverseEnumerator._obj
00000000005d66e8 s _OBJC_IVAR_$___NSArrayReversed._array
00000000005d66e0 s _OBJC_IVAR_$___NSArrayReversed._cnt

0000000000007d90 t +[__NSArray0 _alloc]
000000000011fd70 t +[__NSArray0 allocWithZone:]
00000000001b6b20 t +[__NSArrayI __new::::]
00000000001b6b00 t +[__NSArrayI allocWithZone:]
00000000001b6a00 t +[__NSArrayI automaticallyNotifiesObserversForKey:]
00000000001b7270 t +[__NSArrayI_Transfer __transferNew:::]
00000000001b7250 t +[__NSArrayI_Transfer allocWithZone:]
00000000001b6e50 t +[__NSArrayI_Transfer automaticallyNotifiesObserversForKey:]
0000000000127b90 t +[__NSArrayM __new:::]
0000000000127ce0 t +[__NSArrayM __transferNew:::]
0000000000127e10 t +[__NSArrayM allocWithZone:]
0000000000125f70 t +[__NSArrayM automaticallyNotifiesObserversForKey:]

0000000000007dc0 t -[__NSArray0 _init]
0000000000062a70 t -[__NSArray0 autorelease]
000000000011fde0 t -[__NSArray0 copyWithZone:]
0000000000094b20 t -[__NSArray0 copy]
000000000003f2f0 t -[__NSArray0 count]
000000000011fd60 t -[__NSArray0 dealloc]
000000000011fd50 t -[__NSArray0 init]
000000000011fe00 t -[__NSArray0 objectAtIndex:]
000000000011fe60 t -[__NSArray0 objectEnumerator]
000000000003f300 t -[__NSArray0 release]
000000000011fdf0 t -[__NSArray0 retainCount]
000000000003f2e0 t -[__NSArray0 retain]
0000000000083630 t -[__NSArrayI copyWithZone:]
0000000000048530 t -[__NSArrayI countByEnumeratingWithState:objects:count:]
0000000000031230 t -[__NSArrayI count]
00000000000316f0 t -[__NSArrayI dealloc]
00000000000899a0 t -[__NSArrayI enumerateObjectsWithOptions:usingBlock:]
000000000003ebc0 t -[__NSArrayI getObjects:range:]
00000000001b6c30 t -[__NSArrayI mutableCopyWithZone:]
0000000000031250 t -[__NSArrayI objectAtIndex:]
00000000001b6aa0 t -[__NSArrayI objectAtIndexedSubscript:]
00000000001b7340 t -[__NSArrayI_Transfer copyWithZone:]
00000000001b6e60 t -[__NSArrayI_Transfer countByEnumeratingWithState:objects:count:]
00000000001b6c70 t -[__NSArrayI_Transfer count]
00000000001b72c0 t -[__NSArrayI_Transfer dealloc]
00000000001b6ef0 t -[__NSArrayI_Transfer enumerateObjectsWithOptions:usingBlock:]
00000000001b6d00 t -[__NSArrayI_Transfer getObjects:range:]
00000000001b7360 t -[__NSArrayI_Transfer mutableCopyWithZone:]
00000000001b6c90 t -[__NSArrayI_Transfer objectAtIndex:]
00000000001b71e0 t -[__NSArrayI_Transfer objectAtIndexedSubscript:]
000000000004a0c0 t -[__NSArrayM _mutate]
0000000000027d20 t -[__NSArrayM addObject:]
000000000003eeb0 t -[__NSArrayM copyWithZone:]
0000000000075220 t -[__NSArrayM countByEnumeratingWithState:objects:count:]
0000000000027870 t -[__NSArrayM count]
000000000002b320 t -[__NSArrayM dealloc]
0000000000087f60 t -[__NSArrayM enumerateObjectsWithOptions:usingBlock:]
000000000010ee90 t -[__NSArrayM exchangeObjectAtIndex:withObjectAtIndex:]
0000000000038620 t -[__NSArrayM getObjects:range:]
0000000000078050 t -[__NSArrayM indexOfObjectIdenticalTo:]
0000000000027d80 t -[__NSArrayM insertObject:atIndex:]
0000000000125f80 t -[__NSArrayM insertObjects:count:atIndex:]
0000000000127e60 t -[__NSArrayM mutableCopyWithZone:]
0000000000028d80 t -[__NSArrayM objectAtIndex:]
0000000000126ad0 t -[__NSArrayM objectAtIndexedSubscript:]
00000000000a2eb0 t -[__NSArrayM removeAllObjects]
0000000000098940 t -[__NSArrayM removeLastObject]
00000000000862c0 t -[__NSArrayM removeObjectAtIndex:]
0000000000126b80 t -[__NSArrayM removeObjectsInRange:]
000000000003ed00 t -[__NSArrayM replaceObjectAtIndex:withObject:]
0000000000127630 t -[__NSArrayM replaceObjectsInRange:withObjects:count:]
000000000009a2f0 t -[__NSArrayM setObject:atIndex:]
0000000000127890 t -[__NSArrayM setObject:atIndexedSubscript:]
00000000000a0fd0 t -[__NSArrayReverseEnumerator dealloc]
00000000000a0ee0 t -[__NSArrayReverseEnumerator initWithObject:]
00000000000a0f60 t -[__NSArrayReverseEnumerator nextObject]
00000000001978f0 t -[__NSArrayReversed count]
0000000000197b30 t -[__NSArrayReversed dealloc]
0000000000197990 t -[__NSArrayReversed getObjects:range:]
0000000000197ae0 t -[__NSArrayReversed initWithArray:]
0000000000197910 t -[__NSArrayReversed objectAtIndex:]
*/

/*
00000000005d6ec0 s _OBJC_CLASS_$___NSPlaceholderArray
00000000005d6ee8 s _OBJC_METACLASS_$___NSPlaceholderArray

0000000000129ce0 t +[__NSPlaceholderArray allocWithZone:]
0000000000006f90 t +[__NSPlaceholderArray immutablePlaceholder]
0000000000006e70 t +[__NSPlaceholderArray initialize]
0000000000023cc0 t +[__NSPlaceholderArray mutablePlaceholder]

0000000000129e30 t -[__NSPlaceholderArray _initByAdoptingBuffer:count:size:]
0000000000129920 t -[__NSPlaceholderArray count]
0000000000129ea0 t -[__NSPlaceholderArray dealloc]
0000000000129cf0 t -[__NSPlaceholderArray initWithArray:copyItems:]
0000000000023cd0 t -[__NSPlaceholderArray initWithCapacity:]
000000000009fe30 t -[__NSPlaceholderArray initWithContentsOfFile:]
0000000000099170 t -[__NSPlaceholderArray initWithContentsOfURL:]
0000000000006fa0 t -[__NSPlaceholderArray initWithObjects:count:]
000000000003e820 t -[__NSPlaceholderArray init]
0000000000129aa0 t -[__NSPlaceholderArray insertObject:atIndex:]
00000000001299e0 t -[__NSPlaceholderArray objectAtIndex:]
0000000000129e80 t -[__NSPlaceholderArray release]
0000000000129b60 t -[__NSPlaceholderArray removeObjectAtIndex:]
0000000000129c20 t -[__NSPlaceholderArray replaceObjectAtIndex:withObject:]
0000000000129e90 t -[__NSPlaceholderArray retainCount]
0000000000129e70 t -[__NSPlaceholderArray retain]

0000000000006ea0 t ___34+[__NSPlaceholderArray initialize]_block_invoke
0000000000129dd0 t ___48-[__NSPlaceholderArray initWithArray:copyItems:]_block_invoke
*/

/*
00000000005d6e48 s _OBJC_CLASS_$___NSFrozenArrayM
00000000005d6e98 s _OBJC_METACLASS_$___NSFrozenArrayM

00000000001285a0 t +[__NSFrozenArrayM __new::::]
0000000000128780 t +[__NSFrozenArrayM __transferNew:::]
00000000001287f0 t +[__NSFrozenArrayM allocWithZone:]
0000000000127f70 t +[__NSFrozenArrayM automaticallyNotifiesObserversForKey:]

0000000000128860 t -[__NSFrozenArrayM copyWithZone:]
00000000001280a0 t -[__NSFrozenArrayM countByEnumeratingWithState:objects:count:]
0000000000127f80 t -[__NSFrozenArrayM count]
0000000000128810 t -[__NSFrozenArrayM dealloc]
0000000000128110 t -[__NSFrozenArrayM enumerateObjectsWithOptions:usingBlock:]
0000000000128320 t -[__NSFrozenArrayM getObjects:range:]
0000000000128530 t -[__NSFrozenArrayM indexOfObjectIdenticalTo:]
0000000000128880 t -[__NSFrozenArrayM mutableCopyWithZone:]
0000000000127fa0 t -[__NSFrozenArrayM objectAtIndex:]
0000000000128020 t -[__NSFrozenArrayM objectAtIndexedSubscript:]

00000000005d6190 s _OBJC_IVAR_$___NSFrozenArrayM.cow
00000000005d6188 s _OBJC_IVAR_$___NSFrozenArrayM.storage
*/

/*
00000000005d88b0 s _OBJC_CLASS_$___NSSingleObjectArrayI
00000000005d88d8 s _OBJC_METACLASS_$___NSSingleObjectArrayI

00000000005d68c8 s _OBJC_IVAR_$___NSSingleObjectArrayI._object

00000000001c5cf0 t +[__NSSingleObjectArrayI __new::]
00000000001c5cd0 t +[__NSSingleObjectArrayI allocWithZone:]
00000000001c5a80 t +[__NSSingleObjectArrayI automaticallyNotifiesObserversForKey:]

00000000001c5db0 t -[__NSSingleObjectArrayI copyWithZone:]
00000000001c5a90 t -[__NSSingleObjectArrayI countByEnumeratingWithState:objects:count:]
00000000001c5960 t -[__NSSingleObjectArrayI count]
00000000001c5d50 t -[__NSSingleObjectArrayI dealloc]
00000000001c5b10 t -[__NSSingleObjectArrayI enumerateObjectsWithOptions:usingBlock:]
00000000001c5b80 t -[__NSSingleObjectArrayI firstObject]
00000000001c59e0 t -[__NSSingleObjectArrayI getObjects:range:]
00000000001c5ba0 t -[__NSSingleObjectArrayI isEqualToArray:]
00000000001c5c60 t -[__NSSingleObjectArrayI lastObject]
00000000001c5dd0 t -[__NSSingleObjectArrayI mutableCopyWithZone:]
00000000001c5970 t -[__NSSingleObjectArrayI objectAtIndex:]
00000000001c5c80 t -[__NSSingleObjectArrayI objectEnumerator]
*/
