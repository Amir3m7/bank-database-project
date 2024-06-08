from browser import document, ajax, console, window, html

def handle_response(req):
    if req.status == 200:  # Successful response
        result=req.text
        result=eval(result.replace('false','False').replace('true','True'))
        # console.log(result)
        if len(result)>0:
            for account in result:
                tableRow = html.TR()
                for fild in account:
                    table_data = html.TD(f"{fild}")
                    tableRow <= table_data
                table = document["customers"]  # Get the table element by its ID
                table <= tableRow
    else:
        print("Request failed:", req.status)

req = ajax.ajax()
req.bind('complete', handle_response)
req.open('POST', '/transactionSecc')
req.send()
