from browser import document, ajax, console, window, html

def handle_response(req):
    if req.status == 200:  # Successful response
        result=req.text
        result=eval(result.replace('false','False').replace('true','True').replace('null',"'NULL'"))
        console.log(result)
        if len(result)>0:
            document['message'].innerHTML=""
            document['customers'].innerHTML=""
            tableRow = html.TR()
            table_header = html.TH("payment id")
            tableRow <= table_header
            table_header = html.TH("payment")
            tableRow <= table_header
            table_header = html.TH("loan id")
            tableRow <= table_header
            table_header = html.TH("loan part")
            tableRow <= table_header
            table_header = html.TH("payment date")
            tableRow <= table_header
            table_header = html.TH("paid")
            tableRow <= table_header
            table = document["customers"] 
            table <= tableRow
            for account in result:
                tableRow = html.TR()
                for fild in account:
                    table_data = html.TD(f"{fild}")
                    tableRow <= table_data
                table = document["customers"]  # Get the table element by its ID
                table <= tableRow
        else:
            document['table'].innerHTML="<h2>this loan have not any peyment</h2>"
    else:
        print("Request failed:", req.status)

def loading():
    req = ajax.ajax()
    req.bind('complete', handle_response)
    req.open('POST', f'/loanId')
    req.send()


loading()




def handle_pay(req):
    if req.status == 200:  # Successful response
        result=req.text
        console.log(result)
        if result=='0':
            document['message'].innerHTML="you can't pay!!"
        else:
            loading()
    else:
        print("Request failed:", req.status)

def pay(ev):
    account=document['pay'].value
    req = ajax.ajax()
    req.bind('complete', handle_pay)
    req.open('POST', '/loanId?action=pay')
    req.send()


document["pay"].bind("click", pay)