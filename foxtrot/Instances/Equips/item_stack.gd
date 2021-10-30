extends "res://Instances/Equips/item.gd"

export var max_stack_amt  : int = 64
export var curr_stack_amt : int = 1
export var isInfiniteUse  : bool = false

func Use():
  # Do not allow item usage if no player is using it.
  # Probably should disable object processing until in use...
  if player_inv == null: return
  
  # Do not subtract from stack if infinite uses
  if not isInfiniteUse:
    
    # Subtract usages left from item
    curr_stack_amt -= 1
    
    # Inform UI to update current stack amount
    player_inv.RefreshInventoryForItemInUse()
    
    # If no more projectiles left to shoot, delete this item
    if curr_stack_amt == 0:
      if player_inv.RemoveItem(self) == OK:
        self.queue_free()
      else:
        print("[ItemStack] Error. Failed to remove item from player inventory.")

func AddToStack(amount):
  # Add amount to stack 
  curr_stack_amt += amount
  
  if curr_stack_amt > max_stack_amt:
    # Check how much of the amount  was unused
    var overflow = curr_stack_amt - max_stack_amt
    
    # Set stack size to the max
    curr_stack_amt = max_stack_amt
    
    # Return the amount unused
    return overflow
  
  # If this is reached, then all of the amount was used
  return 0

func ToJSON():
  return {
    Save.SAVE_ID : id,
    Save.SAVE_CURR_STACK_AMT : curr_stack_amt
   }

func FromJSON(item):
  self.id = item[Save.SAVE_ID]
  self.curr_stack_amt = item[Save.SAVE_CURR_STACK_AMT]
