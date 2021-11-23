extends Item
class_name ItemStack

# The max stacking capacity of the item
export var max_stack_amt  : int = 64

# The current stack amount on this item
export var curr_stack_amt : int = 1

# Whether the player can use the item infinitely
export var isInfiniteUse  : bool = false

func Use():
  var success = _on_use()
  
  # Do not subtract from stack if infinite uses
  if not isInfiniteUse && success:
    
    # Subtract usages remaining
    curr_stack_amt -= 1
    
    # Inform UI to update current stack amount
    player_inv.RefreshInventoryForItemInUse()
    
    # If no more items left to use, delete this item
    if curr_stack_amt == 0:
      if player_inv.RemoveItem(self) == OK:
        self.queue_free()
      else:
        printerr("[ItemStack] Error. Failed to remove item from player inventory...")

func AddToStack(amount):
  # Purpose   : Adds the amount provided to the item's stack
  # Param(s)  :
  # - amount  : the quantity to add to the stack
  # Return(s) : the amount that could not be added to the stack because of max capacity
  
  # Add amount to stack 
  curr_stack_amt += amount
  
  if curr_stack_amt > max_stack_amt:
    # Check how much of the amount  was unused
    var overflow = curr_stack_amt - max_stack_amt
    
    # Set stack size to the max
    curr_stack_amt = max_stack_amt
    
    # Return the amount unused
    return overflow
  
  # If this line is reached, then all of the amount was used
  return 0

func ToJSON():
  return {
    Save.SAVE_ID : id,
    Save.SAVE_CURR_STACK_AMT : curr_stack_amt
   }

func FromJSON(item):
  .FromJSON(item)
  self.curr_stack_amt = item[Save.SAVE_CURR_STACK_AMT]

func Pickup():
  # Purpose   : Used to let the player pick up the item and place it in the player inventory
  # Param(s)  : N/A
  # Return(s) : N/A
  if Equips.equips[id].subtype == Equips.Subtype.stackable:
    Signals.emit_signal("on_inventory_add_item_stack", id, curr_stack_amt)
    self.queue_free()
  else:
    .Pickup()
