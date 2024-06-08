#connecting to DB-------------------------------------------------------------------
import psycopg2
dbname = "db_project"
dbuser = "postgres"
dbpassword = "123"
def connectToDB(query,procedure=False):
    conn = psycopg2.connect(dbname=dbname, user=dbuser, password=dbpassword)#default host is localhost
    cursor = conn.cursor()
    # query = "select login_user('ami','1234');"
    cursor.execute(query)
    results = cursor.fetchall()
    # print(type(results)) (list)
    # print(type(results[0])) (tuple)
    # print(type(results[0][0])) (bool)
    conn.commit()
    cursor.close()
    conn.close()
    return results
# print(connectToDB("select login_user('ami','1234');"))
#----------------------------------------------------------------------------------


from flask import Flask, request, render_template, redirect, url_for, session
app = Flask(__name__)
app.secret_key = '1357'

@app.route('/',methods=['GET'])
def index():
    if 'username' in session:
        return redirect(url_for('mainPage'))
    return render_template("login.html")
    

@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'username' in session:
        return redirect(url_for('mainPage'))        
    if request.method == 'POST':
        username=request.args['username']
        password=request.args['password']
        user = connectToDB(f"select login_user('{username}','{password}');")[0][0]
        if user:
            session['username'] = username
            return redirect(url_for('mainPage'))
    return '0'



@app.route('/mainPage', methods=['GET', 'POST'])
def mainPage():
    if request.method == 'POST':
        if 'username' in session:
            return session['username']
        return "Please log in."
    elif request.method=='GET':
        if 'username' in session:
            return render_template("mainPage.html")
        return "Please log in."

@app.route('/logout')
def logout():
    session.pop('username', None)
    return render_template("login.html")

@app.route('/accountDetail',methods=['GET', 'POST'])
def accountDetail():
    if request.method == 'GET':
        if 'username' in session:
            return render_template("accountDetail.html")
    elif request.method=='POST' and 'username' in session:
        result=connectToDB(f"select * from all_account_with_info('{session['username']}');")
        return result
    return "Please log in."


def isOwenerOfAcount(username,acount):
    return connectToDB(f"select check_account_with_username('{username}','{acount}');")[0][0]

@app.route('/transfer',methods=['GET', 'POST'])
def transfer():
    if request.method == 'GET':
        if 'username' in session:
            return render_template("transfer.html")
    elif 'amount' not in request.args:
        if 'username' in session:
            if 'destination' not in request.args:
                source=request.args['source']
                if isOwenerOfAcount(session['username'],source):
                    return '1'
                else:
                    return '0'
            destination=request.args['destination']
            user = connectToDB(f"select * from account_name('{destination}');")
            if(user[0][0] is None):
                return '0'
            else:
                return user[0][0]
    else:
        destination=request.args['destination']
        amount=request.args['amount']
        source=request.args['source']
        if isOwenerOfAcount(session["username"],source):
            user = connectToDB(f"select * from account_name('{destination}');")
            if(user[0][0] is None):
                return '0'
            print('connecting to DB')
            result = connectToDB(f"select transaction('{source}','{destination}',{amount});")
            print(result)
            if result[0][0]:
                session['dst']=destination
                session['src']=source
                session['amount']=amount
                return '1'
        return '0'
    return "Please log in."


@app.route('/recentTurnover',methods=['GET', 'POST'])
def recentTurnover():
    if request.method == 'GET':
        if 'username' in session:
            return render_template("recentTurnover.html")
    elif request.method=='POST' and 'username' in session:
        if isOwenerOfAcount(session['username'],request.args['account'])==False:
            return '0'
        result=connectToDB(f"select * from get_recent_transactions('{request.args['account']}',{request.args['numberInput']})")
        print(f"select * from get_recent_transactions('{request.args['account']}',{request.args['numberInput']})")
        print(result)
        return result
    return "Please log in."

@app.route('/accountTurnoverBetween',methods=['GET', 'POST'])
def accountTurnoverBetween():
    if request.method == 'GET':
        if 'username' in session:
            return render_template("accountTurnoverBetween.html")
    elif request.method=='POST' and 'username' in session:
        if isOwenerOfAcount(session['username'],request.args['account'])==False:
            return '0'
        result=connectToDB(f"select * from get_transaction_with_date('{request.args['account']}','{request.args['from']}','{request.args['to']}')")
        return result
    return "Please log in."

@app.route('/accountBlocking',methods=['GET', 'POST'])
def accountBlocking():
    if request.method == 'GET':
        if 'username' in session:
            return render_template("accountBlocking.html")
    elif request.method=='POST' and 'username' in session:
        if isOwenerOfAcount(session['username'],request.args['account'])==False:
            return '0'
        blockd=connectToDB(f"select blocked from accounts where account_number='{request.args['account']}';")[0][0]
        if blockd and connectToDB(f"select unblock_account('{request.args['account']}')")[0][0]:
            return '2'
        elif blockd==False and connectToDB(f"select block_account('{request.args['account']}')")[0][0]:
            return '1'
        else:
            return '0'
    return "Please log in."

@app.route('/loans',methods=['GET', 'POST'])
def loans():
    if request.method == 'GET':
        if 'username' in session:
            # if 'loanId' in request.args:
            #     session['loanId']=request.args['loanId']
            #     return redirect(url_for("loanId"))
            return render_template("loans.html")
    elif request.method=='POST' and 'username' in session:
        if 'action' not in request.args:
            user=connectToDB(f"select get_id('{session['username']}');")[0][0]
            result=connectToDB(f"select * from loans_of_user({user});")
            return result
        elif request.args['action']=="point" and isOwenerOfAcount(session["username"],request.args['account']):
            result=connectToDB(f"select loan_point('{request.args['account']}');")
            # print(str(result[0][0]))
            return str(result[0][0])
        elif isOwenerOfAcount(session["username"],request.args['account']):
            account=request.args['account']
            result=connectToDB(f"select get_loan('{account}');")
            return result
    return "0"


@app.route('/loanId',methods=['GET', 'POST'])
def loanId():
    print(request.method)
    if (request.method=='GET'):
        session['loanId']=request.args['loanId']
        return render_template('loanId.html')
    elif request.method=='POST' and 'action' in request.args:
        result=connectToDB(f"select pay_loan('{session['loanId']}');")
        return '1'
    elif request.method=='POST' and 'action' not in request.args:
        return connectToDB(f"select * from list_payment('{session['loanId']}');")
    return "Please log in."


@app.route('/transactionSecc',methods=['GET', 'POST'])
def transactionSecc():
    if request.method == 'GET':
        if 'username' in session:
            return render_template("transactionSecc.html")
    elif request.method=='POST':
        result=[[session['dst'],session['src'],session['amount']],]
        return result
    return "Please log in."

if __name__ == '__main__':
    app.run(debug=True)
