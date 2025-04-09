# Full DSL example for an account management system
# This example demonstrates a simple account management system with transaction handling.
# The system allows users to view account details, manage transactions, and close accounts.

## DATA MODEL
ENTITY: Account, 1.0.0, "Financial Account"

COLLECTIONS:
  types: ENUM STR
    savings = "Savings"
    checking = "Checking"
    credit = "Credit"

  currencies: ARRAY<STR> = ["USD", "EUR", "GBP"]

PROPERTIES:
  id:
    type        : INT
    required    : true
    auto        : true
    primary_key : true
    readonly    : true

  account_number:
    type        : STR
    required    : true
    unique      : true

  name:
    type        : STR
    required    : true
    max_length  : 100

  type:
    type        : ENUM types
    required    : true

  balance:
    type        : DECIMAL
    default     : 0.00
    readonly    : true

  currency:
    type        : STR
    in          : currencies
    default     : "USD"

  active:
    type        : BOOL
    default     : true

  owner_id:
    type        : INT
    ref         : Person.id
    required    : true

  created_at:
    type        : DATETIME
    default     : NOW
    readonly    : true

TRIGGERS:
  on_deactivate:
    IF active IS FALSE
    THEN SET name TO CONCAT(name, " [Closed]")

GUARDS:
  prevent_update_if_inactive:
    ON UPDATE
    IF active IS FALSE AND NOT (active CHANGES)
    THEN BLOCK WITH "Cannot modify closed accounts"

  prevent_delete_with_balance:
    ON DELETE
    IF balance > 0
    THEN BLOCK WITH "Cannot delete account with non-zero balance"

SIDE_EFFECTS:
  ON DELETE:
    FOR Transaction WHERE account_id == THIS
    SET account_id TO NULL


ENTITY: Transaction, 1.0.0, "Account Transaction"

PROPERTIES:
  id:
    type        : INT
    required    : true
    auto        : true
    primary_key : true

  account_id:
    type        : INT
    ref         : Account.id
    required    : true

  date:
    type        : DATETIME
    required    : true

  description:
    type        : STR
    required    : true

  amount:
    type        : DECIMAL
    required    : true

  type:
    type        : STR
    required    : true
    values      : ["credit", "debit"]

  created_by:
    type        : STR
    required    : true


## FORM DEFINITION
ENTITY: Account, 1.0.0, "Account Form"

PARAMETERS:
  account: Account
  transactions: COLLECTION OF Transaction = EMPTY
  canEdit: BOOL = true
  loadTransactions: FUNC

STATE:
  account: @@account
  transactions: @@transactions
  context: PermissionContext

CONDITIONS:
  isAdmin: @context.role = "admin"
  isSavings: @account.type = "savings"
  canDelete: @account.balance = 0
  hasTransactions: LENGTH OF @transactions > 0
  isInactive: @account.active = false

TEMPLATES:
  transaction_row:
    PARAMETERS:
      tx: Transaction
      canRemove: BOOL = false

    STATE:
      rowId: CONCAT("tx-", @tx.id)
      buttonId: CONCAT("remove-", @tx.id)

    LAYOUT:
      HORIZONTAL_STACK gap=2:
        DIV: content: @tx.date
        DIV: content: @tx.description
        DIV: content: @tx.amount
        DIV: content: @tx.type
        BUTTON:
          id: @buttonId
          label: "Remove"

    VIEW_LOGIC:
      #@buttonId:
        hidden: NOT canRemove

    ACTIONS:
      #@buttonId:
        on: click
        call: @context.removeTransaction
        with:
          id: @tx.id

  empty_tx_list:
    LAYOUT:
      DIV: content: "No transactions available"

  account_card:
    PARAMETERS:
      title: STR

    LAYOUT:
      DIV:
        class: "card"

        HEADER: content: @title

        SLOT: content

        SLOT: actions
          WHEN canEdit?

LAYOUT:
  ~account_card:
    title: "Account Details"

    IN SLOT content:
      HORIZONTAL_GRID gap=2:
        COLUMN width=50%:
          @account.account_number
          @account.name

        COLUMN width=50%:
          @account.type
          @account.currency

      @account.owner_id
      @account.active

    IN SLOT actions:
      BUTTON:
        id: "closeBtn"
        label: "Close Account"

  IF @account.active:
    ASYNC:
      loader: @loadTransactions
      target: @transactions

      FOR @transactions AS tx:
        ~transaction_row:
          tx: tx
          canRemove: isAdmin?

  ELSE IF isInactive?:
    ~empty_tx_list

  ELSE:
    DIV: content: "Account not found or inaccessible."

VIEW_LOGIC:
  #closeBtn:
    hidden: NOT canEdit?
    tooltip:
      WHEN isInactive? THEN: "Account already closed"
      ELSE: "Click to close account"

  @account.name:
    readonly: NOT canEdit?

STYLE:
  #closeBtn:
    class:
      WHEN isInactive? THEN: "btn-disabled"
      ELSE: "btn-warning"

  @account.name:
    background: VAR(cl-input-bg)

ACTIONS:
  #closeBtn:
    on: click
    call: context.closeAccount
    with:
      id: @account.id
