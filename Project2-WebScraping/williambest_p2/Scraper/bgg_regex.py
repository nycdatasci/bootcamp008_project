import re

# regexes that will be used
ratings_comments_re = re.compile(r"\s*Ratings & Comments\s*")
game_designer_re = re.compile(r"/boardgamedesigner/.*")
full_credits_re = re.compile(r"\s*Full Credits\s*")
designers_re = re.compile(r"Designers")

std_re = re.compile("\sStd. Deviation\s")
comments_re = re.compile(r"\s*Comments\s*")
fans_re = re.compile(r"\s*Fans\s*")
weight_re = re.compile(r"\s*Weight\s*")
plays_re = re.compile(r"\s*All Time Plays\s*")
own_re = re.compile(r"\s*Own\s*")
prev_owned_re = re.compile(r"\s*Prev. Owned\s*")

non_integer_re = re.compile(r"[^\d]")
non_float_re = re.compile(r"[^\d.]")
integer_re = re.compile(r"\d+")


# removes all non-digits from a string to return an integer
# if anything goes wrong, just return None
def clean_integer(integer_string):
    rez = None
    try:
        rez = int(re.sub(non_integer_re, '', integer_string))
    except (ValueError, NameError, TypeError) as e:
        pass  # keep rez as None
    finally:
        return rez


def clean_float(float_string):
    rez = None
    try:
        rez = float(re.sub(non_float_re, '', float_string))
    except (ValueError, NameError, TypeError) as e:
        pass  # keep rez as None
    finally:
        return rez
