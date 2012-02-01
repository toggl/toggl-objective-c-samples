#import <Foundation/Foundation.h>

@interface TogglClient : NSObject {
	BOOL is_reachable;
}

@property BOOL is_reachable;

- (NSDictionary *) create_session:(NSString *)username password:(NSString *)password;
- (NSDictionary *) get_me;
- (void) destroy_task:(long)task_id;
- (NSDictionary *) update_task:(long)task_id task_data:(NSMutableDictionary *)task_data;
- (NSDictionary *) create_task:(NSMutableDictionary *)task_data;
- (NSDictionary *) create_project:(NSMutableDictionary *)project_data;

@end
