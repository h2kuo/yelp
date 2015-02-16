//
//  FiltersViewController.m
//  Yelp
//
//  Created by Helen Kuo on 2/10/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"
#import "ChoiceCell.h"

@interface FiltersViewController ()  <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, strong) NSArray *tableSections;
@property (nonatomic, assign) BOOL deals;
@property (nonatomic, strong) NSArray *sortBys;
@property (nonatomic, strong) NSArray *distances;
@property (nonatomic, assign) NSInteger sortBy;
@property (nonatomic, assign) NSInteger distance;
@property (nonatomic, strong) NSMutableArray *isExpanded;
@property (nonatomic, strong) NSMutableArray *selectedValues;



-(void)initCategories;
-(NSInteger)selectedValue:(NSInteger)section;
-(bool)isChoiceSection:(NSInteger)section;

@end

@implementation FiltersViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        [self initCategories];
        self.tableSections = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"Offering a deal", nil], self.sortBys, self.distances, self.categories, nil];
        self.selectedValues = [NSMutableArray arrayWithObjects:@0, @0, @0, @-1, nil];
        self.isExpanded = [NSMutableArray arrayWithObjects:@(YES), @(NO), @(NO), @(NO), nil];
        NSLog(@"%@", self.isExpanded);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 48;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ChoiceCell" bundle:nil] forCellReuseIdentifier:@"ChoiceCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Switch cell delegate methods

-(void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 0) {
        self.deals = value;
        return;
    }
    if (value) {
        [self.selectedCategories addObject:self.categories[indexPath.row]];
    } else {
        [self.selectedCategories removeObject:self.categories[indexPath.row]];
    }
}

#pragma mark - Table methods

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch(section)
    {
        case 0:
            return @"Most Popular";
        case 1:
            return @"Sort By";
        case 2:
            return @"Distance";
        case 3:
            return @"Categories";
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self.isExpanded[section] boolValue]) {
        if (section == 3) {
            return 6;
        }
        return 1;
    }
    return [self.tableSections[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableSections.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        BOOL isExpanded = [self.isExpanded[indexPath.section] boolValue];
    if (![self isChoiceSection:indexPath.section] && (isExpanded || (!isExpanded && indexPath.row != 5))) {
        return;
    }

    if ([self isChoiceSection:indexPath.section] && isExpanded) {
        self.selectedValues[indexPath.section] = [NSNumber numberWithInteger:indexPath.row];
    }
    self.isExpanded[indexPath.section] = @(!isExpanded);
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isChoiceSection:indexPath.section]) {
        ChoiceCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ChoiceCell"];
        if (![[self.isExpanded objectAtIndex:indexPath.section] boolValue]) {
            cell.titleLabel.text = self.tableSections[indexPath.section][[self selectedValue:indexPath.section]][@"name"];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            return cell;
        }
        if (indexPath.row == [self.selectedValues[indexPath.section] integerValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.titleLabel.text = self.tableSections[indexPath.section][indexPath.row][@"name"];
        return cell;
    }
    SwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    if (indexPath.section == 3) {
        if (![self.isExpanded[indexPath.section] boolValue] && indexPath.row == 5) {
            cell.titleLabel.text = @"Show More...";
            cell.toggleSwitch.hidden = YES;
        } else {
            cell.toggleSwitch.hidden = NO;
            cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            cell.titleLabel.text = self.categories[indexPath.row][@"name"];
        }
    } else {
        cell.on = self.deals;
        cell.titleLabel.text = self.tableSections[indexPath.section][indexPath.row];
    }
    cell.delegate = self;
    return cell;
}

#pragma mark - Private methods


-(BOOL)isChoiceSection:(NSInteger)section {
    return section == 1 || section == 2;
}

-(NSInteger)selectedValue:(NSInteger)section {
    return [self.selectedValues[section] integerValue];
}

-(NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    [filters setObject:self.tableSections[1][[self selectedValue:1]][@"code"] forKey:@"sort"];
    [filters setObject: self.deals ? @"true" : @"false" forKey:@"deals_filter"];
    [filters setObject: self.tableSections[2][[self selectedValue:2]][@"code"] forKey:@"radius_filter"];
    return filters;
}

-(void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initCategories {
    self.sortBys =
    @[
      @{@"name" : @"Best Matched", @"code" : @0},
      @{@"name" : @"Distance", @"code" : @1},
      @{@"name" : @"Highest Rated", @"code" : @2}];
    
    self.distances =
    @[
      @{@"name" : @"0.3 mi", @"code" : @804},
      @{@"name" : @"1 mi", @"code" : @1609},
      @{@"name" : @"5 mi", @"code" : @8046},
      @{@"name" : @"20 mi", @"code" : @32186}];
    
    self.categories =
    @[
      @{@"name" : @"Afghan", @"code": @"afghani" },
      @{@"name" : @"African", @"code": @"african" },
      @{@"name" : @"Senegalese", @"code": @"senegalese" },
      @{@"name" : @"South African", @"code": @"southafrican" },
      @{@"name" : @"American, New", @"code": @"newamerican" },
      @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
      @{@"name" : @"Arabian", @"code": @"arabian" },
      @{@"name" : @"Argentine", @"code": @"argentine" },
      @{@"name" : @"Armenian", @"code": @"armenian" },
      @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
      @{@"name" : @"Australian", @"code": @"australian" },
      @{@"name" : @"Austrian", @"code": @"austrian" },
      @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
      @{@"name" : @"Barbeque", @"code": @"bbq" },
      @{@"name" : @"Basque", @"code": @"basque" },
      @{@"name" : @"Belgian", @"code": @"belgian" },
      @{@"name" : @"Brasseries", @"code": @"brasseries" },
      @{@"name" : @"Brazilian", @"code": @"brazilian" },
      @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
      @{@"name" : @"British", @"code": @"british" },
      @{@"name" : @"Buffets", @"code": @"buffets" },
      @{@"name" : @"Burgers", @"code": @"burgers" },
      @{@"name" : @"Burmese", @"code": @"burmese" },
      @{@"name" : @"Cafes", @"code": @"cafes" },
      @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
      @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
      @{@"name" : @"Cambodian", @"code": @"cambodian" },
      @{@"name" : @"Caribbean", @"code": @"caribbean" },
      @{@"name" : @"Dominican", @"code": @"dominican" },
      @{@"name" : @"Haitian", @"code": @"haitian" },
      @{@"name" : @"Puerto Rican", @"code": @"puertorican" },
      @{@"name" : @"Trinidadian", @"code": @"trinidadian" },
      @{@"name" : @"Catalan", @"code": @"catalan" },
      @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
      @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
      @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
      @{@"name" : @"Chinese", @"code": @"chinese" },
      @{@"name" : @"Cantonese", @"code": @"cantonese" },
      @{@"name" : @"Dim Sum", @"code": @"dimsum" },
      @{@"name" : @"Shanghainese", @"code": @"shanghainese" },
      @{@"name" : @"Szechuan", @"code": @"szechuan" },
      @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
      @{@"name" : @"Corsican", @"code": @"corsican" },
      @{@"name" : @"Creperies", @"code": @"creperies" },
      @{@"name" : @"Cuban", @"code": @"cuban" },
      @{@"name" : @"Czech", @"code": @"czech" },
      @{@"name" : @"Delis", @"code": @"delis" },
      @{@"name" : @"Diners", @"code": @"diners" },
      @{@"name" : @"Fast Food", @"code": @"hotdogs" },
      @{@"name" : @"Filipino", @"code": @"filipino" },
      @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
      @{@"name" : @"Fondue", @"code": @"fondue" },
      @{@"name" : @"Food Court", @"code": @"food_court" },
      @{@"name" : @"Food Stands", @"code": @"foodstands" },
      @{@"name" : @"French", @"code": @"french" },
      @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
      @{@"name" : @"German", @"code": @"german" },
      @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
      @{@"name" : @"Greek", @"code": @"greek" },
      @{@"name" : @"Halal", @"code": @"halal" },
      @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
      @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
      @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
      @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
      @{@"name" : @"Hot Pot", @"code": @"hotpot" },
      @{@"name" : @"Hungarian", @"code": @"hungarian" },
      @{@"name" : @"Iberian", @"code": @"iberian" },
      @{@"name" : @"Indian", @"code": @"indpak" },
      @{@"name" : @"Indonesian", @"code": @"indonesian" },
      @{@"name" : @"Irish", @"code": @"irish" },
      @{@"name" : @"Italian", @"code": @"italian" },
      @{@"name" : @"Japanese", @"code": @"japanese" },
      @{@"name" : @"Ramen", @"code": @"ramen" },
      @{@"name" : @"Teppanyaki", @"code": @"teppanyaki" },
      @{@"name" : @"Korean", @"code": @"korean" },
      @{@"name" : @"Kosher", @"code": @"kosher" },
      @{@"name" : @"Laotian", @"code": @"laotian" },
      @{@"name" : @"Latin American", @"code": @"latin" },
      @{@"name" : @"Colombian", @"code": @"colombian" },
      @{@"name" : @"Salvadorean", @"code": @"salvadorean" },
      @{@"name" : @"Venezuelan", @"code": @"venezuelan" },
      @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
      @{@"name" : @"Malaysian", @"code": @"malaysian" },
      @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
      @{@"name" : @"Falafel", @"code": @"falafel" },
      @{@"name" : @"Mexican", @"code": @"mexican" },
      @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
      @{@"name" : @"Egyptian", @"code": @"egyptian" },
      @{@"name" : @"Lebanese", @"code": @"lebanese" },
      @{@"name" : @"Modern European", @"code": @"modern_european" },
      @{@"name" : @"Mongolian", @"code": @"mongolian" },
      @{@"name" : @"Moroccan", @"code": @"moroccan" },
      @{@"name" : @"Pakistani", @"code": @"pakistani" },
      @{@"name" : @"Persian/Iranian", @"code": @"persian" },
      @{@"name" : @"Peruvian", @"code": @"peruvian" },
      @{@"name" : @"Pizza", @"code": @"pizza" },
      @{@"name" : @"Polish", @"code": @"polish" },
      @{@"name" : @"Portuguese", @"code": @"portuguese" },
      @{@"name" : @"Poutineries", @"code": @"poutineries" },
      @{@"name" : @"Russian", @"code": @"russian" },
      @{@"name" : @"Salad", @"code": @"salad" },
      @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
      @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
      @{@"name" : @"Scottish", @"code": @"scottish" },
      @{@"name" : @"Seafood", @"code": @"seafood" },
      @{@"name" : @"Singaporean", @"code": @"singaporean" },
      @{@"name" : @"Slovakian", @"code": @"slovakian" },
      @{@"name" : @"Soul Food", @"code": @"soulfood" },
      @{@"name" : @"Soup", @"code": @"soup" },
      @{@"name" : @"Southern", @"code": @"southern" },
      @{@"name" : @"Spanish", @"code": @"spanish" },
      @{@"name" : @"Sri Lankan", @"code": @"srilankan" },
      @{@"name" : @"Steakhouses", @"code": @"steak" },
      @{@"name" : @"Sushi Bars", @"code": @"sushi" },
      @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
      @{@"name" : @"Tapas Bars", @"code": @"tapas" },
      @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
      @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
      @{@"name" : @"Thai", @"code": @"thai" },
      @{@"name" : @"Turkish", @"code": @"turkish" },
      @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
      @{@"name" : @"Uzbek", @"code": @"uzbek" },
      @{@"name" : @"Vegan", @"code": @"vegan" },
      @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
      @{@"name" : @"Vietnamese", @"code": @"vietnamese" }];
}

@end
