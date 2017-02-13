import pandas as pd
import unittest
import json
import numpy as np


def load_data(file_name):
    with open(file_name) as d:
        data = json.load(d)
        d.close()
    return pd.DataFrame(data)


def remove_punc_nan(df, col, punc):
    holder = []
    for item in df[col]:
        if not type(item) is float:
            item = item.strip(str(punc))
        holder.append(item)
    df[col] = holder
    return df


class TestColsIfClean(unittest.TestCase):

    def __init__(self, df):
        self.df = df

    def test_col_has_no_empty_string(self, df, col):
        check = '' in df[col]
        self.assertEqual(check, False)

    def test_cols_have_no_empty_strings(self, df):
        for cols in self.df.columns:
            self.test_col_has_no_empty_string(df=self.df, col=cols)


if __name__ == '__main__':
    df = load_data('../data/products2.json')
    # 1_star - DONE
    # 2_star - DONE
    # 3_star - DONE
    # 4_star - DONE
    # 5_star - DONE
    star_cols = ['1_star', '2_star', '3_star', '4_star', '5_star']
    for star in star_cols:
        remove_punc_nan(df, star, '%')

    # ASIN - WIP - Ignore/coerce to nan bad ASINs for now
    # Batteries - DONE - DONE
    # Best_Sellers_Rank - DONE
    df.drop(['Best_Sellers_Rank'], axis=1, inplace=True)
    # California_residents - DONE
    # Customer_Reviews - DONE
    df.replace(to_replace=r'(?![0-9][\.])( out of 5 stars)',
               value={'Customer_Reviews': ''}, inplace=True, regex=True)
    df.replace(to_replace='', value={'Customer_Reviews': np.nan}, inplace=True)
    df['Customer_Reviews'] = pd.to_numeric(
        df['Customer_Reviews'], errors='ignore')
    # Department -  - DONE
    # Domestic_Shipping - DONE
    df.replace(to_replace='Item can be shipped within U.S.', value={
               'Domestic_Shipping': 'Domestic'}, inplace=True)
    df.replace(to_replace='This item is not eligible for international \
                           shipping.', value={
               'Domestic_Shipping': 'Domestic'}, inplace=True)
    df.replace(to_replace='This item can be shipped to select countries outside\
                           of the U.S.', value={
               'Domestic_Shipping': 'International'}, inplace=True)
    df.replace(to_replace='Currently, item can be shipped only within the U.S. \
                            and to APO/FPO addresses. For APO/FPO shipments, \
                            please check with the manufacturer regarding \
                            warranty and support issues.',
               value={'Domestic_Shipping': 'Domestic'}, inplace=True)

    # International_Shipping - WIP--use: # (?=International)*(?=Domestic)*
    df.drop(['International_Shipping'], axis=1, inplace=True)

    # Item_Weight - DONE
    # Item_model_number - DONE
    # Manufacturer - DONE
    # Manufacturer_recommended_age - DONE
    # Media - DONE
    # Origin - DONE
    # Pricing - DONE
    # Product_Dimensions - DONE
    df.replace(to_replace='Currently, item can be shipped only within the U.S. \
                            and to APO/FPO addresses. For APO/FPO shipments, \
                            please check with the manufacturer regarding \
                            warranty and support issues.',
               value={'Product_Dimensions': np.nan}, inplace=True)
    df.replace(to_replace='Item can be shipped within U.S.',
               value={'Product_Dimensions': np.nan}, inplace=True)

    # Release_date - DONE

    # Shipping_Information - DONE
    df.drop(['Shipping_Information'], axis=1, inplace=True)

    # Shipping_Weight - DONE

    # about - DONE
    df.replace(to_replace='', value={'about': np.nan}, inplace=True)

    # avg_rating - DONE
    df.replace(to_replace=r'(?![0-9][\.])( out of 5 stars)',
               value={'avg_rating': ''}, inplace=True, regex=True)
    df.replace(to_replace='', value={'avg_rating': np.nan}, inplace=True)
    df['avg_rating'] = pd.to_numeric(df['avg_rating'], errors='ignore')
    # category - DONE

    # description - DONE
    df.replace(to_replace='', value={'description': np.nan}, inplace=True)

    # in_stock - WIP -- drop for now until regex are finalized
    df.drop(['in_stock'], axis=1, inplace=True)
    # df.replace(to_replace=r'(?![0-9])?(?=\s+left in stock.)*(Only\s+|\s+left in stock - order soon.\s+)+',
    #            value={'in_stock': ''}, inplace=True, regex=True)
    # df.replace(to_replace=r'(?![0-9])?(\s+left in stock.)+',
    #            value={'in_stock': ''}, inplace=True, regex=True)
    # df.replace(to_replace=r'(Sold by Amazon Appstore|In Stock\.|Available from these sellers\.)', value={
    #            'in_stock': '9999'}, inplace=True, regex=True)

    # list_price - DONE
    df['list_price'].fillna(value=0, inplace=True)
    df.replace(to_replace=r'\$', value={
               'list_price': ''}, inplace=True, regex=True)
    df['list_price'] = pd.to_numeric(df['list_price'], errors='ignore')
    df.replace(to_replace=0, value={'list_price': np.nan}, inplace=True)

    # sale_price - DONE
    df['sale_price'].fillna(value=0, inplace=True)
    df.replace(to_replace=r'\$', value={
               'sale_price': ''}, inplace=True, regex=True)
    df['sale_price'] = pd.to_numeric(df['sale_price'], errors='ignore')

    # num_questions - DONE
    df.replace(to_replace=r'(?![0-9])(.)+',
               value={'num_questions': ''}, inplace=True, regex=True)
    df.replace(to_replace='', value={'num_questions': np.nan}, inplace=True)
    df['num_questions'] = pd.to_numeric(df['num_questions'], errors='ignore')

    # num_reviews - DONE
    df.replace(to_replace=r'(\,)', value={
               'num_reviews': ''}, inplace=True, regex=True)
    df['num_reviews'] = pd.to_numeric(df['num_reviews'], errors='ignore')

    # product_title - DONE
    df.replace(to_replace='', value={'product_title': np.nan}, inplace=True)

    # reviews_url - DONE
    # root_or_child - DONE
    # shipping - DONE
    # url - DONE

    # subset of data for further analysis
    df_mod = df.loc[
        (~df['1_star'].isnull()) &
        (~df['2_star'].isnull()) &
        (~df['3_star'].isnull()) &
        (~df['4_star'].isnull()) &
        (~df['5_star'].isnull()) &
        (~df['ASIN'].isnull()),
    ]

    df_mod.to_csv('../data/products_cleaned.csv')

    # RUN TESTS
    unittest.main(df_mod)
