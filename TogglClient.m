#import "TogglClient.h"
#import "JSON.h"
#import "DateHelper.h"

const static NSString *kTogglApiUrl = @"https://www.toggl.com/api/v6";

@implementation TogglClient

@synthesize is_reachable;

- (id)init {
    if ((self = [super init])) {
		self.is_reachable = YES;
    }
    return self;
}

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

- (id) executeJSONRequest:(NSDictionary *)params url:(NSString *)url with_method:(NSString *)with_method {
	DLog(@"executeJsonRequest url: %@", url);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:url]];
	
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];  
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];  
	
	if ([@"POST" isEqualToString:with_method] || [@"PUT" isEqualToString:with_method]) {
		SBJsonWriter *writer = [SBJsonWriter new];
		NSString *json = [writer stringWithObject:params];
		NSString *requestString = [NSString stringWithFormat:@"%@", json, nil];
		DLog(@"request string: %@", requestString);
		[request setHTTPBody:[requestString dataUsingEncoding:NSUTF8StringEncoding]]; 
	}
	
	[request setHTTPMethod: with_method];

	NSError *error = nil;
	NSURLResponse *response = nil;

	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&error];
	[request release];

	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	int statusCode = [httpResponse statusCode];
	if (403 == statusCode) {
		@throw [NSException exceptionWithName:@"TogglException" reason:@"Access denied" userInfo:nil];
	} else if (500 == statusCode) {
		@throw [NSException exceptionWithName:@"TogglException" reason:@"Server error" userInfo:nil];
	} else if (400 == statusCode) {
		NSString *returnString = [[NSString alloc] initWithData:returnData encoding: NSUTF8StringEncoding];
		@throw [NSException exceptionWithName:@"TogglException" reason:returnString userInfo:nil];
	} else if ((200 != statusCode) && (0 != statusCode)) {
		@throw [NSException exceptionWithName:@"TogglException" reason:[NSString stringWithFormat:@"Request failed, HTTP status code: %d", statusCode] userInfo:nil];
	}
	
	if (nil != error) {
		self.is_reachable = NO;
		DLog(@"error: %@", error);
		NSException *exception = [NSException exceptionWithName:@"ConnectionException" reason:@"Could not sync with Toggl.com. Are you offline?" userInfo:[error userInfo]];
		@throw exception;		
	} else {
		self.is_reachable = YES;
	}
	
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding: NSUTF8StringEncoding];
	DLog(@"response string: %@", returnString);
	
	id decodedJsonObject = nil;

	if (0 != [returnString length]) {
		decodedJsonObject = [[returnString JSONValue] valueForKey:@"data"];
	}
	[returnString release];
	
	return decodedJsonObject;
}

- (id) get:(NSString *)url {
	return [self executeJSONRequest:nil url:url with_method:@"GET"];
}

- (id) post:(NSDictionary *)params url:(NSString *)url {
	return [self executeJSONRequest:params url:url with_method:@"POST"];
}

- (id) destroy:(NSString *)url {
	return [self executeJSONRequest:nil url:url with_method:@"DELETE"];
}

- (id) put:(NSDictionary *)params url:(NSString *)url {
	return [self executeJSONRequest:params url:url with_method:@"PUT"];
}

+ (NSString *) api_url:(NSString *)path {
	return [NSString stringWithFormat:@"%@/%@", kTogglApiUrl, path];
}

- (void) handle_validation_errors:(NSMutableDictionary *)data {
	NSArray *validation_errors = [data objectForKey:@"errors"];
	if (nil != validation_errors) {
		for (NSMutableDictionary *error in validation_errors) {
			NSString *reason = [error objectForKey:@"message"];
			NSException *exception = [NSException exceptionWithName:@"TogglException" reason:reason userInfo:data];
			@throw exception;
		}
	}
}

#pragma mark API methods

- (NSDictionary *) create_session:(NSString *)username password:(NSString *)password {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: username, @"email", password, @"password", nil];
	NSString *url = [TogglClient api_url:@"sessions.json"];
	return [self post:params url:url];
}

- (NSDictionary *) get_me {
	NSString *url = [TogglClient api_url:@"me.json?with_related_data=true"];
	return [self get:url];
}

- (NSDictionary *) update_task:(long)task_id task_data:(NSMutableDictionary *)task_data {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: task_data, @"time_entry", @"PUT", @"_method", nil];
	NSString *url = [NSString stringWithFormat:@"%@/%d.json", 
					 [TogglClient api_url:@"time_entries"],
					 task_id];
	return [self put:params url:url];
}

- (NSDictionary *) create_task:(NSMutableDictionary *)task_data {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: task_data, @"time_entry", nil];
	NSString *url = [TogglClient api_url:@"time_entries"];
	return [self post:params url:url];
}

- (void) destroy_task:(long)task_id {
	NSString *url = [NSString stringWithFormat:@"%@/%d.json", 
									 [TogglClient api_url:@"time_entries"],
									 task_id];
	[self destroy:url];
}
	
- (NSDictionary *) create_project:(NSMutableDictionary *)project_data {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: project_data, @"project", nil];
	NSString *url = [TogglClient api_url:@"projects"];
	return [self post:params url:url];
}

@end
