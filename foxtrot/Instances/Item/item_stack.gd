extends "res://Instances/Item/item.gd"

export var max_stack_amt  : int = 64
export var curr_stack_amt : int = 1

func Use():
  # Do not allow item usage if no player is using it.
  # Probably should disable object processing until in use...
  if player_inv == null: return
  
  curr_stack_amt -= 1
  
  # If no more projectiles are present, delete this item
  if curr_stack_amt == 0:
    if player_inv.RemoveItem(self) == OK:
      self.queue_free()
    else:
      print("[ItemStack] Error. Failed to remove item from player inventory.")
