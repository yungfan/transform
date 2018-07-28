//
//  ViewController.m
//  大小写转换
//
//  Created by 杨帆 on 16/3/1.
//  Copyright © 2016年 ahachj. All rights reserved.
//

#import "ViewController.h"

static NSString* MONEY_TOO_BIG = @"MONEY_TOO_BIG";

@interface ViewController ()

//输入的金额
@property (weak, nonatomic) IBOutlet UITextField* inputNumber;
//转换按钮
- (IBAction)transform:(id)sender;
//输出的大写金额
@property (weak, nonatomic) IBOutlet UILabel* outputNumber;

//汉语中数字大写
@property (nonatomic, strong) NSArray* CN_UPPER_NUMBER;
//人民币单位一，仟以下
@property (nonatomic, strong) NSArray* CN_UPPER_MONEY_UNIT_ONE;
//人民币单位二，万以下
@property (nonatomic, strong) NSArray* CN_UPPER_MONEY_UNIT_TWO;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark 懒加载
- (NSArray*)CN_UPPER_NUMBER
{

    if (_CN_UPPER_NUMBER == nil) {
        _CN_UPPER_NUMBER = @[ @"零", @"壹", @"贰", @"叁", @"肆", @"伍", @"陆", @"柒", @"捌", @"玖" ];
    }

    return _CN_UPPER_NUMBER;
}
#pragma mark 懒加载
- (NSArray*)CN_UPPER_MONEY_UNIT_ONE
{

    if (_CN_UPPER_MONEY_UNIT_ONE == nil) {
        _CN_UPPER_MONEY_UNIT_ONE = @[ @"", @"拾", @"佰", @"仟" ];
    }

    return _CN_UPPER_MONEY_UNIT_ONE;
}
#pragma mark 懒加载
- (NSArray*)CN_UPPER_MONEY_UNIT_TWO
{

    if (_CN_UPPER_MONEY_UNIT_TWO == nil) {
        _CN_UPPER_MONEY_UNIT_TWO = @[ @"", @"万", @"亿", @"万亿" ];
    }

    return _CN_UPPER_MONEY_UNIT_TWO;
}

#pragma mark - 数字转货币大小写
- (NSString*)changetochinese:(NSString*)numstr
{
    double numberals = [numstr doubleValue];

    //小数点后保留2位，这样无论如何valstr的长度都会大于4
    NSString* valstr = [NSString stringWithFormat:@"%.2f", numberals];

    //整数部分最后的结果
    NSString* prefix = @"";
    //小数部分最后的结果
    NSString* suffix = @"";
    //分割出整数与小数
    unsigned long flag = valstr.length - 2;
    //整数部分
    NSString* head = [valstr substringToIndex:flag - 1];
    //小数部分
    NSString* foot = [valstr substringFromIndex:flag];
    //金额太大
    if (head.length > 13) {

        return MONEY_TOO_BIG;
    }
    /**
     *有整数部分的情况，否则 prefix = @""，正好和后面的小数点部分拼接
     *处理整数部分
     */
    if ([head intValue] != 0) {
        //处理整数部分
        NSMutableArray* ch = [[NSMutableArray alloc] init];

        //将整数部分按照从高位到低位的顺序放到ch数组中去
        for (int i = 0; i < head.length; i++) {

            //减去ascll码中的 ‘0’的值 意思就是把head[i]这个元素变成0-9的数字。如果是‘6’在ascll码中就是54, 减去‘0’ 的48,就是等与数字的6
            NSString* str = [NSString stringWithFormat:@"%x", [head characterAtIndex:i] - '0'];
            [ch addObject:str];
        }

        //记录整数部分的数字一共有多少个0
        int zeroCount = 0;
        for (int i = 0; i < ch.count; i++) {
            int index = (ch.count - i - 1) % 4; //取段内位置
            unsigned long indexloc = (ch.count - i - 1) / 4; //取段位置

            //判断循环取出的当前数字时不时0
            if ([[ch objectAtIndex:i] isEqualToString:@"0"]) {
                zeroCount++;
            }
            //如果不是0
            else {
                //并且已经取出的也没有0
                if (zeroCount != 0) {
                    if (index != 3) {
                        prefix = [prefix stringByAppendingString:@"零"];
                    }
                    zeroCount = 0;
                }
                //拼接大写数字
                prefix = [prefix stringByAppendingString:[self.CN_UPPER_NUMBER objectAtIndex:[[ch objectAtIndex:i] intValue]]];

                //拼接单位（仟以下）
                prefix = [prefix stringByAppendingString:[self.CN_UPPER_MONEY_UNIT_ONE objectAtIndex:index]];
            }
            
            if (index == 0 && zeroCount < 4) {
                //拼接单位（万以上）
                prefix = [prefix stringByAppendingString:[self.CN_UPPER_MONEY_UNIT_TWO objectAtIndex:indexloc]];
            }
        }
        prefix = [prefix stringByAppendingString:@"元"];
    }
    
    /**
     * 处理小数位
     */
    
    //两位小数为00，说明只有整数部分
    if ([foot isEqualToString:@"00"]) {
        suffix = [suffix stringByAppendingString:@"整"];
    }
    //小数部分只有第一位为0，也就是说没有角有分
    else if ([foot hasPrefix:@"0"]) {
        NSString* footch = [NSString stringWithFormat:@"%x", [foot characterAtIndex:1] - '0'];
        suffix = [NSString stringWithFormat:@"%@分", [self.CN_UPPER_NUMBER objectAtIndex:[footch intValue]]];
    }
    //分和角都有
    else {
        NSString* headch = [NSString stringWithFormat:@"%x", [foot characterAtIndex:0] - '0'];
        NSString* footch = [NSString stringWithFormat:@"%x", [foot characterAtIndex:1] - '0'];
        suffix = [NSString stringWithFormat:@"%@角%@分", [self.CN_UPPER_NUMBER objectAtIndex:[headch intValue]], [self.CN_UPPER_NUMBER objectAtIndex:[footch intValue]]];
    }

    return [prefix stringByAppendingString:suffix];
}

#pragma mark - 点击按钮事件
- (IBAction)transform:(id)sender
{

    [self.inputNumber resignFirstResponder];
    self.outputNumber.hidden = NO;

    //判断输入金额是否为空
    if ([self.inputNumber.text isEqualToString:@""]) {

        self.outputNumber.text = @"😂,您没有输入任何金额";
        self.outputNumber.textColor = [UIColor redColor];
    }

    else {

        NSString* output = [self changetochinese:self.inputNumber.text];

        //判断金额是不是太大
        if ([output isEqualToString:MONEY_TOO_BIG]) {
            self.outputNumber.textColor = [UIColor redColor];
            self.outputNumber.text = @"😂,输入的金额最大支持13位整数";
        }

        else {
            self.outputNumber.textColor = [UIColor blueColor];
            self.outputNumber.text = output;
        }
    }
}

#pragma mark - 点击屏幕退出键盘
- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    [self.inputNumber resignFirstResponder];
}

@end
