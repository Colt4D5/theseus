export interface Story {
  id: string,
  authorId: string,
  prompt: string,
  content: string,
  createdAt: Date,
}

export interface Matchup {
  id: string,
  prompt: string,
  userStoryId: string,
  aiStoryId: string,
  createdAt: Date,
}

export interface Vote {
  id: string,
  matchupId: string,
  voterId: string,
  choice: 'user' | 'ai',
  createdAt: Date,
}