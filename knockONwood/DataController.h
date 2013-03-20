
#import <Foundation/Foundation.h>

//singleton class
@interface DataController : NSObject {
	
	NSString *baseURL;
 
}

@property (nonatomic, strong) NSString *baseURL;

// SINGLETON BUSINESS
+ (DataController *) dc;
+ (id) allocWithZone : (NSZone *)zone;
- (id) copyWithZone : (NSZone *)zone;

@end
