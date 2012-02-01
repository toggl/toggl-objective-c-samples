
#define kSecondsPerDay (24 * 60 * 60)

@interface DateHelper : NSObject {

}

#pragma mark Convert datetime to date

+ (int) seconds_to_days:(long)seconds;
+ (int) nsdate_to_days:(NSDate *)date;
+ (NSString *) nsdate_to_date_string:(NSDate *)date;

#pragma mark Formatting

+ (NSString *) format_date:(NSDate *)date;
+ (NSString *) format_seconds:(long)seconds with_seconds:(BOOL)with_seconds;

#pragma mark Convert timestamp to NSDate

+ (NSDate *) seconds_to_nsdate:(long)seconds;

#pragma mark Convert NSDate to timestamp

+ (long) nsdate_to_seconds:(NSDate *)date;

#pragma mark Shortcuts

+ (long) current_timestamp_in_seconds;
+ (long) current_date_in_days;
+ (long) current_timestamp_in_seconds_without_time_part;
+ (NSDate *) yesterday;
+ (NSDate *) tomorrow;
+ (NSDate *) add_days:(int) days;

#pragma mark ISO8601 formatting and parsing

+ (NSString *) nsdate_to_iso8601_string:(NSDate *)date;
+ (NSDate *) iso8601_string_to_nsdate:(NSString *)string;

@end
