//
//  UIView+SetupEngine.m
//  UIViewSetupEngine
//
//  Created by hncoder on 2017/3/17.
//  Copyright © 2017年 hncoder. All rights reserved.
//

#import "UIView+SetupEngine.h"


//v:{{x,y},{w,h}}:(123,234,567)
//l:{{x,y},{w,h}}:(123,234,567):@16:@@text:|-:-|-:-|:-:--
//i:{{x,y},{w,h}}:@@name:
//t
//b

@interface NSString(UISetupEngine)
- (BOOL)se_containsString:(NSString *)str;

- (Class)se_Class;
- (NSValue *)se_rectValue;
- (NSNumber *)se_fontSize;
- (NSString *)se_text;
- (NSNumber *)se_textAlignment;
- (UIColor *)se_color;
@end

@implementation NSString(UISetupEngine)
- (BOOL)se_containsString:(NSString *)str
{
    return str && [self rangeOfString:str].location != NSNotFound;
}

- (Class)se_Class
{
    Class c = nil;
    if ([self isEqualToString:@"v"])
    {
        c = [UIView class];
    }
    else if ([self isEqualToString:@"l"])
    {
        c = [UILabel class];
    }
    else if ([self isEqualToString:@"i"])
    {
        c = [UIImageView class];
    }
    else if ([self isEqualToString:@"t"])
    {
        c = [UITextField class];
    }
    else if ([self isEqualToString:@"b"])
    {
        c = [UIButton class];
    }
    
    return c;
}

- (UIColor *)se_color
{
    UIColor *color = nil;
    NSString *colorString = [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"("]];
    NSArray *colorItems = [colorString componentsSeparatedByString:@","];
    if ([colorItems count] == 3)
    {
        color = [UIColor colorWithRed:[colorItems[0] integerValue]/255.0 green:[colorItems[1] integerValue]/255.0 blue:[colorItems[2] integerValue]/255.0 alpha:1.0];
    }
    else if ([colorItems count] == 4)
    {
        color = [UIColor colorWithRed:[colorItems[0] integerValue]/255.0 green:[colorItems[1] integerValue]/255.0 blue:[colorItems[2] integerValue]/255.0 alpha:[colorItems[3] floatValue]];
    }
    
    return color;
}

- (NSValue *)se_rectValue
{
    NSString *rectString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    CGRect rect = CGRectFromString(rectString);
    return [NSValue valueWithCGRect:rect];
}

- (NSNumber *)se_fontSize
{
    NSString *fontSizeString = [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
    return @([fontSizeString integerValue]);
}

- (NSString *)se_text
{
    NSString *textString = [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
    return textString;
}

- (NSNumber *)se_textAlignment
{
    NSString *textAlignmentString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSTextAlignment textAlignment = NSTextAlignmentLeft;
    if ([textAlignmentString isEqualToString:@"|-"])
    {
        textAlignment = NSTextAlignmentLeft;
    }
    else if ([textAlignmentString isEqualToString:@"-|-"])
    {
        textAlignment = NSTextAlignmentCenter;
    }
    else if ([textAlignmentString isEqualToString:@"-|"])
    {
        textAlignment = NSTextAlignmentRight;
    }
    
    return @(textAlignment);
}

@end

@implementation UIView(SetupEngine)
+ (id)setupUIObjectWithFormat:(NSString *)format
{
    UIView *obj = nil;
    
    NSDictionary *UIObjectParams = [self UIObjectParamsWithFormat:format];
    assert([UIObjectParams count]);
    
    do
    {
        Class c = [UIObjectParams objectForKey:@"class"];
        if (!c) break;
        
        obj = [c new];
        if (![obj isKindOfClass:[UIView class]]) break;
        
        NSValue *rect = [UIObjectParams objectForKey:@"rect"];
        if (rect) obj.frame = [rect CGRectValue];
        
        UIColor *color = [UIObjectParams objectForKey:@"color"];
        if (color)
        {
            if ([obj isMemberOfClass:[UIView class]]) ((UIView *)obj).backgroundColor = color;
            else if ([obj isMemberOfClass:[UILabel class]]) ((UILabel *)obj).textColor = color;
            else if ([obj isMemberOfClass:[UITextField class]]) ((UITextField *)obj).textColor = color;
            else if ([obj isMemberOfClass:[UIButton class]]) [((UIButton *)obj) setTitleColor:color forState:UIControlStateNormal];
        }
        
        NSString *text = [UIObjectParams objectForKey:@"text"];
        if (text)
        {
            if ([obj isMemberOfClass:[UILabel class]]) ((UILabel *)obj).text = text;
            else if ([obj isMemberOfClass:[UITextField class]]) ((UITextField *)obj).text = text;
            else if ([obj isMemberOfClass:[UIButton class]]) [((UIButton *)obj) setTitle:text forState:UIControlStateNormal];
        }
        
        NSNumber *fontSize = [UIObjectParams objectForKey:@"fontSize"];
        if (fontSize)
        {
            UIFont *font = [UIFont systemFontOfSize:[fontSize integerValue]];
            if ([obj isMemberOfClass:[UILabel class]]) ((UILabel *)obj).font = font;
            else if ([obj isMemberOfClass:[UITextField class]]) ((UITextField *)obj).font = font;
            else if ([obj isMemberOfClass:[UIButton class]]) ((UIButton *)obj).titleLabel.font = font;
        }
        
        NSNumber *textAlignment = [UIObjectParams objectForKey:@"alignment"];
        if (textAlignment)
        {
            if ([obj isMemberOfClass:[UILabel class]]) ((UILabel *)obj).textAlignment = [textAlignment integerValue];
            else if ([obj isMemberOfClass:[UITextField class]]) ((UITextField *)obj).textAlignment = [textAlignment integerValue];
        }
        
    } while (false);
    
    return obj;
}

+ (NSDictionary *)UIObjectParamsWithFormat:(NSString *)format
{
    NSMutableDictionary *UIObjectParams = [NSMutableDictionary dictionary];
    NSArray *params = [format componentsSeparatedByString:@":"];
    if ([params count] > 0)
    {
        [params enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj length] == 1)
            {
                Class class = [obj se_Class];
                if (class)
                {
                    [UIObjectParams setObject:[obj se_Class] forKey:@"class"];
                }
            }
            else if ([obj se_containsString:@"{{"])
            {
                [UIObjectParams setObject:[obj se_rectValue] forKey:@"rect"];
            }
            else if ([obj se_containsString:@"("])
            {
                UIColor *color = [obj se_color];
                if (color)
                {
                    [UIObjectParams setObject:[obj se_color] forKey:@"color"];
                }
            }
            else if ([obj se_containsString:@"@@"])
            {
                [UIObjectParams setObject:[obj se_text] forKey:@"text"];
            }
            else if ([obj se_containsString:@"@"])
            {
                [UIObjectParams setObject:[obj se_fontSize] forKey:@"fontSize"];
            }
            else if ([obj se_containsString:@"-"])
            {
                [UIObjectParams setObject:[obj se_textAlignment] forKey:@"alignment"];
            }
        }];
    }
    
    return UIObjectParams;
}

@end
