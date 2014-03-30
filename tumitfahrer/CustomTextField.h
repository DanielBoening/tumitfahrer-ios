//
//  CustomTextField.h
//  tumitfahrer
//
//  Created by Pawel Kwiecien on 3/29/14.
//  Copyright (c) 2014 Pawel Kwiecien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomTextField : UITextField<UITextFieldDelegate>

- (instancetype)initWithFrame:(CGRect)frame placeholderText:(NSString*)placeholderText customIconName:(NSString *)customIconName returnKeyType:(UIReturnKeyType)returnKeyType;

@end