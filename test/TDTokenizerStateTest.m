#import "TDTestScaffold.h"

@interface TDTokenizerStateTest : XCTestCase {
    PKTokenizer *t;
    NSString *s;
    PKToken *tok;
}

@end

@implementation TDTokenizerStateTest

- (void)setUp {
    t = [[PKTokenizer alloc] init];
}


- (void)tearDown {
    [t release];
}


- (void)testFallbackStateCast {
    [t setTokenizerState:t.symbolState from:'c' to:'c'];
    [t.symbolState setFallbackState:t.wordState from:'c' to:'c'];
    [t.symbolState add:@"cast"];
 
    t.string = @"foo cast cat";
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(@"foo", tok.stringValue);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"cast", tok.stringValue);

    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"c", tok.stringValue);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(@"at", tok.stringValue);    

    tok = [t nextToken];
    TDEqualObjects(@"«EOF»", tok.stringValue);
    TDTrue(tok.isEOF);
}


- (void)testFallbackStateCastAs {
    [t setTokenizerState:t.symbolState from:'c' to:'c'];
    [t.symbolState setFallbackState:t.wordState from:'c' to:'c'];
    [t.symbolState add:@"cast as"];
    
    t.string = @"foo cast as cat";
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(@"foo", tok.stringValue);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"cast as", tok.stringValue);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"c", tok.stringValue);    
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(@"at", tok.stringValue);    
    
    tok = [t nextToken];
    TDEqualObjects(@"«EOF»", tok.stringValue);
    TDTrue(tok.isEOF);
}


- (void)testTrickyFwdSlash {
    [t.delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:nil];
    
    [t setTokenizerState:t.commentState from:'#' to:'#'];
    [t setTokenizerState:t.commentState from:'/' to:'/'];

    [t.commentState addSingleLineStartMarker:@"##"];
    [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];

    t.commentState.fallbackState = t.symbolState;
    [t.commentState setFallbackState:t.delimitState from:'/' to:'/'];
    
    t.string = @"foo /bar/ /*## */ # baz ## ja";
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(@"foo", tok.stringValue);
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"/bar/", tok.stringValue);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"#", tok.stringValue);

    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(@"baz", tok.stringValue);
    
    tok = [t nextToken];
    TDEqualObjects(@"«EOF»", tok.stringValue);
    TDTrue(tok.isEOF);
}


- (void)testTrickyFwdSlash2 {
    [t.delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:nil];
    
    [t setTokenizerState:t.commentState from:'#' to:'#'];
    [t setTokenizerState:t.commentState from:'/' to:'/'];

    [t.commentState addSingleLineStartMarker:@"##"];
    [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
    
    t.commentState.fallbackState = t.symbolState;
    [t.commentState setFallbackState:t.delimitState from:'/' to:'/'];
    
    t.string = @"## ja";
    
    tok = [t nextToken];
    TDEqualObjects(@"«EOF»", tok.stringValue);
    TDTrue(tok.isEOF);
}


- (void)testTrickyFwdSlash3 {
    [t.delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:nil];
    
    [t setTokenizerState:t.commentState from:'#' to:'#'];
    [t setTokenizerState:t.commentState from:'/' to:'/'];
    
    [t.commentState addSingleLineStartMarker:@"##"];
    [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
    
    t.commentState.fallbackState = t.delimitState;
    [t.commentState setFallbackState:t.symbolState from:'#' to:'#'];
    
    t.string = @"foo /bar/ /*## */ # baz ## ja";
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(@"foo", tok.stringValue);
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"/bar/", tok.stringValue);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"#", tok.stringValue);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(@"baz", tok.stringValue);
    
    tok = [t nextToken];
    TDEqualObjects(@"«EOF»", tok.stringValue);    
    TDTrue(tok.isEOF);
}

@end
