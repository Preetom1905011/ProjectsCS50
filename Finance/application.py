import os

from cs50 import SQL
from flask import Flask, flash, jsonify, redirect, render_template, request, session
from flask_session import Session
from tempfile import mkdtemp
from werkzeug.exceptions import default_exceptions, HTTPException, InternalServerError
from werkzeug.security import check_password_hash, generate_password_hash
import datetime

from helpers import apology, login_required, lookup, usd

# for timezone()
import pytz

# Configure application
app = Flask(__name__)

# Ensure templates are auto-reloaded
app.config["TEMPLATES_AUTO_RELOAD"] = True

# Ensure responses aren't cached
@app.after_request
def after_request(response):
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response

# Custom filter
app.jinja_env.filters["usd"] = usd

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_FILE_DIR"] = mkdtemp()
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///finance.db")

# Make sure API key is set
if not os.environ.get("API_KEY"):
    raise RuntimeError("API_KEY not set")


@app.route("/")
@login_required
def index():
    """Show portfolio of stocks"""
    #select all of the user's current stock and shares
    quote = db.execute("SELECT Symbol, Shares FROM portfolio WHERE id=:id", id=session["user_id"])

    #set total asset to 0 (cash+share value)
    total_cash = 0

    #update each symbol's current price
    for quote in quote:
        symbol = quote["Symbol"]
        shares = quote["Shares"]
        stock = lookup(symbol)
        total = float(shares * stock["price"])
        total_cash += total
        #update portfolio table for current user
        db.execute("UPDATE portfolio SET Shares= :shares, Total= :total WHERE id= :id AND Symbol = :symbol", shares=shares, total=usd(total), id=session["user_id"], symbol=symbol)

    #update total asset by adding users remaining cash from users table
    rem_cash = db.execute("SELECT cash FROM users WHERE id=:id", id = session["user_id"])
    total_cash = round(float(total_cash + rem_cash[0]["cash"]), 2)

    #print updated portfolio
    updated_port = db.execute("SELECT * FROM portfolio WHERE id = :id", id = session["user_id"])

    return render_template("index.html", id=session["user_id"], stocks=updated_port, cash = usd(round(rem_cash[0]["cash"], 2)), total=usd(total_cash))


@app.route("/buy", methods=["GET", "POST"])
@login_required
def buy():
    """Buy shares of stock"""

    if request.method == "POST":
        #get symbol
        symbol = request.form.get("symbol")
        #ensure getting symbol
        if not symbol:
            return apology("Must provide quote symbol")
        #get number of shares
        shares = int(request.form.get("shares"))
        #ensure getting num of shares
        if not shares:
            return apology("Must provide number of shares")
        #check if num of shares is POSITIVE
        if shares <= 0:
            return apology("Number os shares must be greater than 0")
        #check if the quote exists
        quote = lookup(symbol)
        if not quote:
            return apology("Invalid symbol")

        #find remaining cash of user
        result = db.execute("SELECT * FROM users WHERE id = :id", id=session['user_id'])
        check_cash = float(result[0]['cash'])
        #calc total share price
        total_price = float(shares * (quote['price']))

        #check if have enough cash
        if check_cash >= total_price:

            # update user cash
            db.execute("UPDATE users SET cash = cash - :purchase WHERE id = :id", id=session["user_id"], purchase=total_price)

            # Select user shares of that symbol
            user_shares = db.execute("SELECT shares FROM portfolio WHERE id = :id AND Symbol=:symbol", id=session["user_id"], symbol=quote["symbol"])

            # if user doesn't has shares of that symbol, create new stock object
            if not user_shares:
                db.execute("INSERT INTO portfolio (Name, Shares, Price, Total, Symbol, id) VALUES(:name, :shares, :price, :total, :symbol, :id)", name=quote["name"], shares=shares, price=usd(quote["price"]), total=usd(total_price), symbol=quote["symbol"], id=session["user_id"])

            # Else increment the shares count
            else:
                shares_total = user_shares[0]["Shares"] + shares
                db.execute("UPDATE portfolio SET Shares=:shares WHERE id=:id AND Symbol=:symbol", shares=shares_total, id=session["user_id"], symbol=quote["symbol"])

            #update history table
            db.execute("INSERT INTO history (id, symbol, shares, price, transacted) VALUES(:id, :symbol, :shares, :price, :transacted)", id=session["user_id"], symbol=symbol.upper(), shares=shares, price=usd(quote["price"]), transacted=datetime.datetime.now(pytz.timezone('Asia/Dhaka')))
            # return to index
            return redirect("/")


        else:
            return apology("You need more cash to purchase stocks!")



    else:
        return render_template("buy.html")


@app.route("/history")
@login_required
def history():
    """Show history of transactions"""
    stocks = db.execute("SELECT * FROM history WHERE id=:id", id=session["user_id"])
    return render_template("history.html", stocks=stocks)


@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":

        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        rows = db.execute("SELECT * FROM users WHERE username = :username",
                          username=request.form.get("username"))

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(rows[0]["hash"], request.form.get("password")):
            return apology("invalid username and/or password", 403)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")


@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/login")


@app.route("/quote", methods=["GET", "POST"])
@login_required
def quote():
    """Get stock quote."""

    # if user reached route via POST
    if request.method == "POST":

        # ensure symbol was submitted
        if not request.form.get("symbol"):
            return apology("symbol required")

        # look symbol up on Yahoo Finance and check if it was successful
        stock = lookup(request.form.get("symbol"))
        if not stock:
            return apology("symbol is invalid/wasn't found or something else went wrong")

        return render_template("quoted.html", stock=stock)

    else:
        return render_template("quote.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    """Register a user"""
    #forget any user_id
    session.clear()

    if request.method == "POST":

        # ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)
        # ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)
        # ensure password was confirmed
        elif not request.form.get("confirmpass"):
            return apology("must confirm password", 403)

        # check if both passwords match
        elif request.form.get("password") != request.form.get("confirmpass"):
            return apology("password does not match", 403)

        # Hash password / Store password hash_password =
        hashed_password = generate_password_hash(request.form.get("password"))

        #check if user already exists
        rows = db.execute("SELECT * FROM users WHERE username = :username",
                  username = request.form.get("username"))
        if rows:
            return apology("The username is already taken")

        # Add user to database
        result = db.execute("INSERT INTO users (username, hash) VALUES(:username, :hash)",
                username = request.form.get("username"),
                hash = hashed_password)

        rows = db.execute("SELECT * FROM users WHERE username = :username",
                  username = request.form.get("username"))


        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")
    else:
        #if request method = get, show the register page
        return render_template("register.html")


@app.route("/sell", methods=["GET", "POST"])
@login_required
def sell():
    """Sell shares of stock"""

    if request.method == "POST":
        #validate symbol input
        symbol = request.form.get("symbol")
        if not symbol:
            return apology("MUST ENTER A SYMBOL")
        quote = lookup(symbol)
        if not quote:
            return apology("INVALID SYMBOL")

        symbol = quote["symbol"]

        #validate shares input
        shares = int(request.form.get("shares"))
        if not shares:
            return apology("MUST ENTER NUMBER OF SHARES")

        #check the current number of shares of that stock
        stock = db.execute("SELECT Shares FROM portfolio WHERE id=:id AND Symbol=:symbol", id = session["user_id"], symbol=symbol)

        #check if has shares of this stock
        if not stock:
            return apology("YOU DON'T OWN SHARES OF THIS STOCK")
        #check if user has enough shares to sell
        if shares > int(stock[0]["Shares"]) or shares < 0 :
            return apology("YOU DON'T OWN ENOUGH SHARES")

        #find current value of shares
        price = quote["price"]
        total = float(shares * price)

        #update current cash in users table
        db.execute("UPDATE users SET cash= cash + :total WHERE id=:id", total=total, id=session["user_id"])

        #calc rem number of shares of this stock
        shares_total = int(stock[0]["Shares"]) - shares

        #update history table
        db.execute("INSERT INTO history (id, symbol, shares, price, transacted) VALUES(:id, :symbol, :shares, :price, :transacted)", id=session["user_id"], symbol=symbol.upper(), shares= -shares, price=usd(price), transacted=datetime.datetime.now(pytz.timezone('Asia/Dhaka')))

        if shares_total == 0:
            db.execute("DELETE FROM portfolio WHERE id=:id AND Symbol=:symbol", id=session["user_id"], symbol=symbol)
        else:
            #update after sold
            db.execute("UPDATE portfolio SET Shares= :shares_total, Price=:cur_price, Total= Total - :total WHERE id = :id AND Symbol=:symbol", shares_total=shares_total, cur_price=usd(price), total=usd(total), id=session["user_id"], symbol=symbol)


        return redirect("/")
    else:
        return render_template("sell.html")


@app.route("/passwordchange", methods= ["GET", "POST"])
@login_required
def passwordchange():
    """change password"""
    if request.method == "POST":
        oldpass = request.form.get("o_password")
        if not oldpass:
            return apology("Must provide old password!")
        newpass = request.form.get("n_password")
        if not newpass:
            return apology("Must input new password!", 403)
        confirmnewpass = request.form.get("confirm_n_pass")
        if not confirmnewpass:
            return apology("Must confirm new password!", 403)

        if newpass != confirmnewpass:
            return apology("Passwords don't match!")
        #find user data from users table
        rows = db.execute("SELECT * FROM users WHERE id=:id", id=session["user_id"])

        #check if new password is same as the old one or not
        if newpass == oldpass:
            return apology("You typed in the same password!", 403)
        else:
            hash = generate_password_hash(newpass)
            db.execute("UPDATE users SET hash = :hash WHERE id=:id", hash = hash, id = session["user_id"])

        return redirect("/")
    else:
        return render_template("passwordchange.html")

def errorhandler(e):
    """Handle error"""
    if not isinstance(e, HTTPException):
        e = InternalServerError()
    return apology(e.name, e.code)


# Listen for errors
for code in default_exceptions:
    app.errorhandler(code)(errorhandler)
