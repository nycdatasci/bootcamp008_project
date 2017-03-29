from flask import Blueprint
from flask_paginate import Pagination

mod = Blueprint('users', __name__)


@mod.route('/')
def index():
    search = False
    q = request.args.get('q')
    if q:
        search = True

    page = request.args.get('page', type=int, default=1)

    users = User.find(...)
    pagination = Pagination(page=page, total=users.count(), search=search, record_name='users')
    return render_template('users/index.html',
                           users=users,
                           pagination=pagination,
                           )